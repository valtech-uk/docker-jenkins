FROM java:8

ENV JENKINS_HOME=/var/jenkins_home \
    JENKINS_UC=https://updates.jenkins-ci.org \
    COPY_REFERENCE_FILE_LOG=/var/jenkins_home/copy_reference_file.log

# Create runtime director for jenkins and the user we will run jenkins with
COPY jenkins.sh /usr/local/bin/jenkins.sh
COPY plugins.sh /usr/local/bin/plugins.sh

RUN mkdir /opt/jenkins; \
	useradd -d "$JENKINS_HOME" -u 1000 -m -s /bin/bash jenkins; \
	chown jenkins /opt/jenkins; \
	curl -fL https://github.com/krallin/tini/releases/download/v0.5.0/tini-static -o /bin/tini && chmod +x /bin/tini; \
	curl -fL http://mirrors.jenkins-ci.org/war/latest/jenkins.war -o /opt/jenkins/jenkins.war; \
	mkdir -p /opt/jenkins/ref/plugins; \
    chown -R jenkins "$JENKINS_HOME" /opt/jenkins; \
    chmod +x /usr/local/bin/jenkins.sh /usr/local/bin/plugins.sh

# Switch to new jenkins user
USER jenkins

ENTRYPOINT ["/bin/tini", "--", "/usr/local/bin/jenkins.sh"]

# from a derived Dockerfile, can use `RUN plugin.sh active.txt` to setup /usr/share/jenkins/ref/plugins from a support bundle

COPY plugins.txt /plugins.txt
RUN /bin/bash /usr/local/bin/plugins.sh /plugins.txt

EXPOSE 8080 50000
VOLUME /var/jenkins_home