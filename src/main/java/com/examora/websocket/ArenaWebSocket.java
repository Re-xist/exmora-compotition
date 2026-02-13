package com.examora.websocket;

import com.examora.model.ArenaAnswer;
import com.examora.model.ArenaParticipant;
import com.examora.model.ArenaSession;
import com.examora.model.Question;
import com.examora.service.ArenaService;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import jakarta.websocket.*;
import jakarta.websocket.server.PathParam;
import jakarta.websocket.server.ServerEndpoint;
import java.io.IOException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArraySet;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Arena WebSocket Endpoint - Handles real-time communication for arena sessions
 */
@ServerEndpoint("/arena/{sessionId}")
public class ArenaWebSocket {

    private static final Logger logger = Logger.getLogger(ArenaWebSocket.class.getName());
    private static final Gson gson = new GsonBuilder().create();

    // Store sessions by sessionId
    private static final Map<Integer, CopyOnWriteArraySet<Session>> sessionRooms = new ConcurrentHashMap<>();

    // Store participant info by websocket session
    private static final Map<String, ParticipantInfo> participantInfoMap = new ConcurrentHashMap<>();

    private ArenaService arenaService;

    public ArenaWebSocket() {
        this.arenaService = new ArenaService();
    }

    @OnOpen
    public void onOpen(Session session, @PathParam("sessionId") Integer sessionId) {
        try {
            // Add session to room
            sessionRooms.computeIfAbsent(sessionId, k -> new CopyOnWriteArraySet<>()).add(session);

            logger.info("WebSocket connected: sessionId=" + sessionId + ", wsSession=" + session.getId());

            // Send welcome message
            JsonObject welcome = new JsonObject();
            welcome.addProperty("type", "connected");
            welcome.addProperty("sessionId", sessionId);
            sendMessage(session, welcome.toString());

        } catch (Exception e) {
            logger.log(Level.SEVERE, "Error in onOpen", e);
        }
    }

    @OnMessage
    public void onMessage(String message, Session session, @PathParam("sessionId") Integer sessionId) {
        try {
            JsonObject json = JsonParser.parseString(message).getAsJsonObject();
            String type = json.get("type").getAsString();

            logger.info("Received message: type=" + type + " from session=" + session.getId());

            switch (type) {
                case "join":
                    handleJoin(session, sessionId, json);
                    break;
                case "answer":
                    handleAnswer(session, sessionId, json);
                    break;
                case "start":
                    handleStart(session, sessionId, json);
                    break;
                case "pause":
                    handlePause(session, sessionId, json);
                    break;
                case "resume":
                    handleResume(session, sessionId, json);
                    break;
                case "next":
                    handleNext(session, sessionId, json);
                    break;
                case "end":
                    handleEnd(session, sessionId, json);
                    break;
                case "getLeaderboard":
                    sendLeaderboard(sessionId);
                    break;
                case "getQuestion":
                    sendCurrentQuestion(sessionId);
                    break;
                case "heartbeat":
                    handleHeartbeat(session, json);
                    break;
                default:
                    logger.warning("Unknown message type: " + type);
            }
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Error processing message", e);
            sendError(session, "Error processing message: " + e.getMessage());
        }
    }

    @OnClose
    public void onClose(Session session, @PathParam("sessionId") Integer sessionId) {
        try {
            // Remove from room
            CopyOnWriteArraySet<Session> room = sessionRooms.get(sessionId);
            if (room != null) {
                room.remove(session);
            }

            // Update participant connection status
            ParticipantInfo info = participantInfoMap.remove(session.getId());
            if (info != null) {
                try {
                    arenaService.updateConnectionStatus(info.participantId, false);
                } catch (Exception e) {
                    logger.log(Level.WARNING, "Error updating connection status", e);
                }

                // Broadcast participant left
                broadcastParticipantLeft(sessionId, info);

                // Update leaderboard
                sendLeaderboard(sessionId);
            }

            logger.info("WebSocket disconnected: sessionId=" + sessionId);

        } catch (Exception e) {
            logger.log(Level.SEVERE, "Error in onClose", e);
        }
    }

    @OnError
    public void onError(Session session, Throwable error) {
        logger.log(Level.SEVERE, "WebSocket error for session " + session.getId(), error);
    }

    // ================== Message Handlers ==================

    private void handleJoin(Session session, Integer sessionId, JsonObject json) {
        try {
            Integer participantId = json.get("participantId").getAsInt();
            Integer userId = json.get("userId").getAsInt();
            String userName = json.has("userName") ? json.get("userName").getAsString() : "Unknown";

            // Store participant info
            ParticipantInfo info = new ParticipantInfo();
            info.participantId = participantId;
            info.userId = userId;
            info.userName = userName;
            info.sessionId = sessionId;
            participantInfoMap.put(session.getId(), info);

            // Update connection status
            arenaService.updateConnectionStatus(participantId, true);

            // Broadcast participant joined
            broadcastParticipantJoined(sessionId, info);

            // Send current state
            sendLeaderboard(sessionId);

            // If session is active, send current question
            ArenaSession arenaSession = arenaService.getSessionById(sessionId);
            if (arenaSession != null && arenaSession.isInProgress()) {
                sendCurrentQuestion(sessionId);
            }

        } catch (Exception e) {
            logger.log(Level.SEVERE, "Error in handleJoin", e);
            sendError(session, "Failed to join: " + e.getMessage());
        }
    }

    private void handleAnswer(Session session, Integer sessionId, JsonObject json) {
        try {
            ParticipantInfo info = participantInfoMap.get(session.getId());
            if (info == null) {
                sendError(session, "Not joined");
                return;
            }

            Integer questionId = json.get("questionId").getAsInt();
            String answer = json.get("answer").getAsString();
            Integer timeTaken = json.has("timeTaken") ? json.get("timeTaken").getAsInt() : 0;

            // Submit answer
            ArenaAnswer arenaAnswer = arenaService.submitAnswer(
                sessionId, info.participantId, questionId, answer, timeTaken
            );

            // Send answer confirmation to the participant
            JsonObject confirmation = new JsonObject();
            confirmation.addProperty("type", "answerConfirmed");
            confirmation.addProperty("questionId", questionId);
            confirmation.addProperty("selectedAnswer", answer);
            confirmation.addProperty("isCorrect", arenaAnswer.getIsCorrect());
            confirmation.addProperty("scoreEarned", arenaAnswer.getScoreEarned());
            confirmation.addProperty("correctAnswer", arenaAnswer.getCorrectAnswer());
            sendMessage(session, confirmation.toString());

            // Broadcast leaderboard update
            sendLeaderboard(sessionId);

        } catch (Exception e) {
            logger.log(Level.SEVERE, "Error in handleAnswer", e);
            sendError(session, "Failed to submit answer: " + e.getMessage());
        }
    }

    private void handleStart(Session session, Integer sessionId, JsonObject json) {
        try {
            Integer hostId = json.get("hostId").getAsInt();

            arenaService.startSession(sessionId, hostId);

            // Broadcast session started
            JsonObject startMsg = new JsonObject();
            startMsg.addProperty("type", "sessionStarted");
            startMsg.addProperty("sessionId", sessionId);
            broadcast(sessionId, startMsg.toString());

            // Send first question
            sendCurrentQuestion(sessionId);

        } catch (Exception e) {
            logger.log(Level.SEVERE, "Error in handleStart", e);
            sendError(session, "Failed to start session: " + e.getMessage());
        }
    }

    private void handlePause(Session session, Integer sessionId, JsonObject json) {
        try {
            Integer hostId = json.get("hostId").getAsInt();

            arenaService.pauseSession(sessionId, hostId);

            // Broadcast session paused
            JsonObject pauseMsg = new JsonObject();
            pauseMsg.addProperty("type", "sessionPaused");
            pauseMsg.addProperty("sessionId", sessionId);
            broadcast(sessionId, pauseMsg.toString());

        } catch (Exception e) {
            logger.log(Level.SEVERE, "Error in handlePause", e);
            sendError(session, "Failed to pause session: " + e.getMessage());
        }
    }

    private void handleResume(Session session, Integer sessionId, JsonObject json) {
        try {
            Integer hostId = json.get("hostId").getAsInt();

            arenaService.resumeSession(sessionId, hostId);

            // Broadcast session resumed
            JsonObject resumeMsg = new JsonObject();
            resumeMsg.addProperty("type", "sessionResumed");
            resumeMsg.addProperty("sessionId", sessionId);
            broadcast(sessionId, resumeMsg.toString());

        } catch (Exception e) {
            logger.log(Level.SEVERE, "Error in handleResume", e);
            sendError(session, "Failed to resume session: " + e.getMessage());
        }
    }

    private void handleNext(Session session, Integer sessionId, JsonObject json) {
        try {
            Integer hostId = json.get("hostId").getAsInt();

            // Get current session to check if we're at the last question
            ArenaSession arenaSession = arenaService.getSessionById(sessionId);

            arenaService.nextQuestion(sessionId, hostId);

            // Check if session ended
            arenaSession = arenaService.getSessionById(sessionId);
            if (arenaSession.isCompleted()) {
                // Broadcast session ended
                JsonObject endMsg = new JsonObject();
                endMsg.addProperty("type", "sessionEnded");
                endMsg.addProperty("sessionId", sessionId);
                broadcast(sessionId, endMsg.toString());
            } else {
                // Broadcast next question
                sendCurrentQuestion(sessionId);
            }

        } catch (Exception e) {
            logger.log(Level.SEVERE, "Error in handleNext", e);
            sendError(session, "Failed to advance: " + e.getMessage());
        }
    }

    private void handleEnd(Session session, Integer sessionId, JsonObject json) {
        try {
            Integer hostId = json.get("hostId").getAsInt();

            arenaService.endSession(sessionId, hostId);

            // Broadcast session ended
            JsonObject endMsg = new JsonObject();
            endMsg.addProperty("type", "sessionEnded");
            endMsg.addProperty("sessionId", sessionId);
            broadcast(sessionId, endMsg.toString());

        } catch (Exception e) {
            logger.log(Level.SEVERE, "Error in handleEnd", e);
            sendError(session, "Failed to end session: " + e.getMessage());
        }
    }

    private void handleHeartbeat(Session session, JsonObject json) {
        JsonObject response = new JsonObject();
        response.addProperty("type", "heartbeatAck");
        sendMessage(session, response.toString());
    }

    // ================== Broadcast Methods ==================

    private void sendLeaderboard(Integer sessionId) {
        try {
            java.util.List<ArenaParticipant> leaderboard = arenaService.getLeaderboard(sessionId);

            JsonObject msg = new JsonObject();
            msg.addProperty("type", "leaderboard");
            msg.add("data", gson.toJsonTree(leaderboard));

            broadcast(sessionId, msg.toString());

        } catch (Exception e) {
            logger.log(Level.SEVERE, "Error sending leaderboard", e);
        }
    }

    private void sendCurrentQuestion(Integer sessionId) {
        try {
            ArenaSession arenaSession = arenaService.getSessionById(sessionId);
            Question question = arenaService.getCurrentQuestion(sessionId);

            if (question == null) {
                return;
            }

            JsonObject msg = new JsonObject();
            msg.addProperty("type", "question");
            msg.addProperty("questionIndex", arenaSession.getCurrentQuestion());
            msg.addProperty("totalQuestions", arenaSession.getTotalQuestions());
            msg.addProperty("questionTime", arenaSession.getQuestionTime());
            msg.add("data", gson.toJsonTree(question));

            broadcast(sessionId, msg.toString());

        } catch (Exception e) {
            logger.log(Level.SEVERE, "Error sending question", e);
        }
    }

    private void broadcastParticipantJoined(Integer sessionId, ParticipantInfo info) {
        JsonObject msg = new JsonObject();
        msg.addProperty("type", "participantJoined");
        msg.addProperty("participantId", info.participantId);
        msg.addProperty("userName", info.userName);
        broadcast(sessionId, msg.toString());
    }

    private void broadcastParticipantLeft(Integer sessionId, ParticipantInfo info) {
        JsonObject msg = new JsonObject();
        msg.addProperty("type", "participantLeft");
        msg.addProperty("participantId", info.participantId);
        msg.addProperty("userName", info.userName);
        broadcast(sessionId, msg.toString());
    }

    // ================== Utility Methods ==================

    private void broadcast(Integer sessionId, String message) {
        CopyOnWriteArraySet<Session> room = sessionRooms.get(sessionId);
        if (room != null) {
            for (Session s : room) {
                sendMessage(s, message);
            }
        }
    }

    private void sendMessage(Session session, String message) {
        try {
            if (session != null && session.isOpen()) {
                session.getBasicRemote().sendText(message);
            }
        } catch (IOException e) {
            logger.log(Level.WARNING, "Error sending message to session " + session.getId(), e);
        }
    }

    private void sendError(Session session, String error) {
        JsonObject msg = new JsonObject();
        msg.addProperty("type", "error");
        msg.addProperty("message", error);
        sendMessage(session, msg.toString());
    }

    // ================== Inner Classes ==================

    private static class ParticipantInfo {
        Integer participantId;
        Integer userId;
        String userName;
        Integer sessionId;
    }
}
