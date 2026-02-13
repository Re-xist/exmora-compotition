<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.examora.model.Submission" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    String errorMsg = (String) request.getAttribute("error");
    Map<String, Object> detail = (Map<String, Object>) request.getAttribute("detail");

    if (errorMsg != null || detail == null) {
%>
<div id="userDetailContent">
    <div class="text-center py-5">
        <div class="mb-4">
            <i class="bi bi-exclamation-triangle display-1 text-warning"></i>
        </div>
        <h4 class="text-muted mb-3">Data Tidak Ditemukan</h4>
        <p class="text-muted"><%= errorMsg != null ? errorMsg : "Data tidak ditemukan" %></p>
        <p class="small text-muted">Pastikan peserta telah menyelesaikan quiz terlebih dahulu.</p>
    </div>
</div>
<%
        return;
    }

    Submission submission = (Submission) detail.get("submission");
    if (submission == null) {
%>
<div id="userDetailContent">
    <div class="text-center py-5">
        <div class="mb-4">
            <i class="bi bi-exclamation-triangle display-1 text-warning"></i>
        </div>
        <h4 class="text-muted mb-3">Data Tidak Ditemukan</h4>
        <p class="text-muted">Data submission tidak ditemukan</p>
        <p class="small text-muted">Pastikan peserta telah menyelesaikan quiz terlebih dahulu.</p>
    </div>
</div>
<%
        return;
    }

    List<Map<String, Object>> questions = (List<Map<String, Object>>) detail.get("questions");
    Integer correctCount = (Integer) detail.get("correctCount");
    Integer wrongCount = (Integer) detail.get("wrongCount");
    Integer unansweredCount = (Integer) detail.get("unansweredCount");

    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd MMMM yyyy, HH:mm");
    String scoreClass = submission.getScore() >= 86 ? "success" : submission.getScore() >= 76 ? "primary" :
                        submission.getScore() >= 61 ? "info" : submission.getScore() >= 41 ? "warning" : "danger";
%>

<div id="userDetailContent" data-user-name="<%= submission.getUserName() %>" data-quiz-title="<%= submission.getQuizTitle() %>">
    <!-- User Info Header -->
    <div class="row mb-4">
        <div class="col-md-8">
            <div class="d-flex align-items-center mb-3">
                <div class="bg-primary text-white rounded-circle d-flex align-items-center justify-content-center me-3"
                     style="width: 60px; height: 60px; font-size: 24px;">
                    <%= submission.getUserName() != null && submission.getUserName().length() > 0 ?
                        submission.getUserName().substring(0, 1).toUpperCase() : "U" %>
                </div>
                <div>
                    <h4 class="mb-0"><%= submission.getUserName() %></h4>
                    <small class="text-muted">Peserta Quiz</small>
                </div>
            </div>
            <table class="table table-borderless table-sm">
                <tr>
                    <td class="text-muted" width="150">Quiz:</td>
                    <td><strong><%= submission.getQuizTitle() %></strong></td>
                </tr>
                <tr>
                    <td class="text-muted">Waktu Submit:</td>
                    <td><%= submission.getSubmittedAt() != null ? submission.getSubmittedAt().format(dtf) : "-" %></td>
                </tr>
                <tr>
                    <td class="text-muted">Waktu Pengerjaan:</td>
                    <td><%= submission.getFormattedTimeSpent() %></td>
                </tr>
            </table>
        </div>
        <div class="col-md-4">
            <div class="card bg-<%= scoreClass %> text-white h-100">
                <div class="card-body text-center d-flex flex-column justify-content-center">
                    <p class="mb-1 opacity-75">NILAI</p>
                    <h1 class="display-4 mb-0"><%= String.format("%.0f", submission.getScore()) %></h1>
                    <small class="opacity-75">
                        <%= submission.getScore() >= 60 ? "LULUS" : "TIDAK LULUS" %>
                    </small>
                </div>
            </div>
        </div>
    </div>

    <!-- Performance Chart -->
    <div class="row mb-4">
        <div class="col-md-4">
            <div class="card h-100">
                <div class="card-header">
                    <h6 class="mb-0"><i class="bi bi-pie-chart me-2"></i>Performa</h6>
                </div>
                <div class="card-body">
                    <canvas id="userPerformanceChart"
                            data-correct="<%= correctCount %>"
                            data-wrong="<%= wrongCount %>"
                            data-unanswered="<%= unansweredCount %>">
                    </canvas>
                </div>
            </div>
        </div>
        <div class="col-md-8">
            <div class="card h-100">
                <div class="card-header">
                    <h6 class="mb-0"><i class="bi bi-bar-chart me-2"></i>Ringkasan Jawaban</h6>
                </div>
                <div class="card-body">
                    <div class="row text-center">
                        <div class="col-4">
                            <div class="p-3 border rounded bg-success bg-opacity-10">
                                <h3 class="text-success mb-0"><%= correctCount %></h3>
                                <small class="text-muted">Benar</small>
                            </div>
                        </div>
                        <div class="col-4">
                            <div class="p-3 border rounded bg-danger bg-opacity-10">
                                <h3 class="text-danger mb-0"><%= wrongCount %></h3>
                                <small class="text-muted">Salah</small>
                            </div>
                        </div>
                        <div class="col-4">
                            <div class="p-3 border rounded bg-warning bg-opacity-10">
                                <h3 class="text-warning mb-0"><%= unansweredCount %></h3>
                                <small class="text-muted">Tidak Dijawab</small>
                            </div>
                        </div>
                    </div>
                    <div class="mt-3">
                        <div class="progress" style="height: 20px;">
                            <div class="progress-bar bg-success" style="width: <%= (correctCount * 100.0 / submission.getTotalQuestions()) %>%">
                                <%= correctCount %>
                            </div>
                            <div class="progress-bar bg-danger" style="width: <%= (wrongCount * 100.0 / submission.getTotalQuestions()) %>%">
                                <%= wrongCount %>
                            </div>
                            <div class="progress-bar bg-warning" style="width: <%= (unansweredCount * 100.0 / submission.getTotalQuestions()) %>%">
                                <%= unansweredCount %>
                            </div>
                        </div>
                        <small class="text-muted">Total: <%= submission.getTotalQuestions() %> soal</small>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Questions and Answers -->
    <div class="card">
        <div class="card-header">
            <h6 class="mb-0"><i class="bi bi-list-check me-2"></i>Detail Jawaban</h6>
        </div>
        <div class="card-body">
            <% if (questions != null && !questions.isEmpty()) {
                int qNo = 1;
                for (Map<String, Object> q : questions) {
                    String questionText = (String) q.get("questionText");
                    String optionA = (String) q.get("optionA");
                    String optionB = (String) q.get("optionB");
                    String optionC = (String) q.get("optionC");
                    String optionD = (String) q.get("optionD");
                    String correctAnswer = (String) q.get("correctAnswer");
                    String selectedAnswer = (String) q.get("selectedAnswer");
                    Boolean isCorrect = (Boolean) q.get("isCorrect");
                    Boolean answered = (Boolean) q.get("answered");

                    String itemClass = "unanswered";
                    String statusIcon = "<i class='bi bi-dash-circle text-warning'></i>";
                    if (answered != null && answered) {
                        if (isCorrect != null && isCorrect) {
                            itemClass = "correct";
                            statusIcon = "<i class='bi bi-check-circle-fill text-success'></i>";
                        } else {
                            itemClass = "wrong";
                            statusIcon = "<i class='bi bi-x-circle-fill text-danger'></i>";
                        }
                    }
            %>
            <div class="question-item <%= itemClass %>">
                <div class="d-flex justify-content-between align-items-start mb-2">
                    <h6 class="mb-0">
                        <%= statusIcon %>
                        <span class="ms-2"><%= qNo %>. <%= questionText %></span>
                    </h6>
                    <span class="badge bg-<%= "correct".equals(itemClass) ? "success" : "wrong".equals(itemClass) ? "danger" : "warning" %>">
                        <%= "correct".equals(itemClass) ? "Benar" : "wrong".equals(itemClass) ? "Salah" : "Tidak Dijawab" %>
                    </span>
                </div>

                <div class="ms-4">
                    <% for (String opt : new String[]{"A", "B", "C", "D"}) {
                        String optText = opt.equals("A") ? optionA : opt.equals("B") ? optionB :
                                        opt.equals("C") ? optionC : optionD;
                        if (optText == null) continue;

                        String optClass = "";
                        if (opt.equals(correctAnswer)) {
                            optClass = "correct-answer";
                        }
                        if (opt.equals(selectedAnswer) && !opt.equals(correctAnswer)) {
                            optClass = "wrong-answer selected";
                        } else if (opt.equals(selectedAnswer)) {
                            optClass = "correct-answer selected";
                        }
                    %>
                    <div class="option-item <%= optClass %>">
                        <strong><%= opt %>.</strong> <%= optText %>
                        <% if (opt.equals(correctAnswer)) { %>
                            <i class="bi bi-check-lg text-success ms-2"></i>
                        <% } %>
                        <% if (opt.equals(selectedAnswer)) { %>
                            <span class="badge bg-primary ms-2">Jawaban Anda</span>
                        <% } %>
                    </div>
                    <% } %>
                </div>
            </div>
            <%  qNo++;
                }
            } else { %>
            <div class="text-center py-4 text-muted">
                <i class="bi bi-inbox display-4 d-block mb-2"></i>
                Tidak ada data pertanyaan
            </div>
            <% } %>
        </div>
    </div>
</div>
