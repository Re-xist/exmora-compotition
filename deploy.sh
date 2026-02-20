#!/bin/bash
# Deploy Examora to Tomcat

# Find Tomcat container
TOMCAT_CONTAINER=$(docker ps --format "{{.Names}}" | grep tomcat 2>/dev/null)

if [ -n "$TOMCAT_CONTAINER" ]; then
    echo "Found Tomcat container: $TOMCAT_CONTAINER"
    
    # Copy WAR file to container
    echo "Copying WAR file..."
    docker cp target/examora.war $TOMCAT_CONTAINER:/usr/local/tomcat/webapps/ROOT.war
    
    # Restart Tomcat
    echo "Restarting Tomcat..."
    docker restart $TOMCAT_CONTAINER
    
    echo "Deployment completed!"
else
    echo "No Docker Tomcat container found. Trying local deployment..."
    
    # Try local Tomcat directories
    for dir in /usr/local/tomcat /opt/tomcat /var/lib/tomcat*; do
        if [ -d "$dir/webapps" ]; then
            echo "Found Tomcat at $dir"
            cp target/examora.war $dir/webapps/ROOT.war
            echo "WAR file copied to $dir/webapps/ROOT.war"
            echo "Please restart Tomcat manually"
            exit 0
        fi
    done
    
    echo "No Tomcat installation found"
    exit 1
fi
