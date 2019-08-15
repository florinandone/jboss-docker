FROM centos:7

# Install packages necessary to run EAP
RUN yum update -y && yum -y install xmlstarlet saxon augeas bsdtar unzip && yum clean all

# Create a user and group used to launch processes
# The user ID 1000 is the default for the first "regular" user on Fedora/RHEL,
# so there is a high chance that this ID will be equal to the current user
# making it easier to use volumes (no permission issues)
RUN groupadd -r jboss -g 1000 && useradd -u 1000 -r -g jboss -m -d /opt/jboss -s /sbin/nologin -c "JBoss user" jboss && \
    chmod 755 /opt/sjboss

# Set the working directory to jboss' user home directory
WORKDIR /opt/jboss

# User root user to install software
USER root

# Install necessary packages
#RUN yum -y install java-1.7.0-openjdk-devel && yum clean all
# pending test zzz 
RUN yum -y install java-1.8.0-openjdk-devel && yum clean all

# Install jboss-4.0.1sp1
RUN yum -y install wget
USER jboss
RUN cd $home && wget https://sourceforge.net/projects/jboss/files/JBoss/JBoss-4.0.1SP1/jboss-4.0.1sp1.zip && unzip jboss-4.0.1sp1.zip && rm jboss-4.0.1sp1.zip

# Enable remote debugging 
ENV JAVA_OPTS=-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=8000

# Expose the ports we're interested in
# Webserver is running on 8080 
# Adminserver is running on 9990
# Remote debug port can be accessed on 8000
EXPOSE 8080 9990 8000

# Configurations
ENV JBOSS_HOME=/opt/jboss/jboss-4.0.1sp1

RUN chmod +x /opt/jboss/jboss-4.0.1sp1/bin/run.sh 

# Set the default command to run on boot
CMD ["/opt/jboss/jboss-4.0.1sp1/bin/run.sh", "-b", "0.0.0.0"]