FROM centos:centos6

## Install some basic utilities that aren't in the default image
RUN yum -y install vim wget createrepo rpm-build sudo which telnet tar openssh-server openssh-clients ntp git python-setuptools python-devel httpd 
RUN rpm -e --nodeps --justdb glibc-common && yum -y install glibc-common gcc-c++ fontconfig

#Install JAVA
RUN wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/7u55-b13/jdk-7u55-linux-x64.rpm -O jdk-7u55-linux-x64.rpm && yum -y install jdk-7u55-linux-x64.rpm

#Install Maven
RUN  mkdir -p /opt/maven && cd /opt/maven && wget http://apache.cs.utah.edu/maven/maven-3/3.0.5/binaries/apache-maven-3.0.5-bin.tar.gz && tar -xvzf /opt/maven/apache-maven-3.0.5-bin.tar.gz && rm -rf /opt/maven/apache-maven-3.0.5-bin.tar.gz

# Install NodeJs and npm
RUN wget  https://rpm.nodesource.com/setup && chmod +x ./setup && ./setup
RUN yum install -y nodejs-0.10.40


#Install brunch
RUN npm install -g brunch@1.7.13

#To allow bower install behind proxy. See https://github.com/bower/bower/issues/731
RUN git config --global url."https://".insteadOf git://

#Set the ENV variables
ENV JAVA_HOME /usr/java/default
ENV M2_HOME /opt/maven/apache-maven-3.0.5
ENV MAVEN_OPTS -Xmx2048m -XX:MaxPermSize=256m
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$M2_HOME/bin:$JAVA_HOME/bin

