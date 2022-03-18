# Base image
FROM ubuntu:bionic

# Disable user input for geographic area
ARG DEBIAN_FRONTEND=noninteractive

# Setting up working directory
WORKDIR /root

# Updating Ubuntu
RUN apt-get update

# Installing Apache2 on the image
RUN apt-get install apache2 -y

# enabling CGI module in Apache2
RUN a2enmod cgi

# Configuring Aapche2
RUN chown -R root.root /var/www
RUN a2enmod rewrite
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
ENV APACHE_RUN_USER root
ENV APACHE_RUN_GROUP root

# Installing awscli for interactions with AWS
RUN apt-get install awscli -y

# Installing curl
RUN apt-get install curl -y

# Clearing out the local repository of retrieved package files
RUN apt-get clean

# Adding CGI Bash script to list the the contents of Helm Repo Bucket
ADD list_s3_contents.sh /usr/lib/cgi-bin

# Container will listen on port 80
EXPOSE 80

# Health Check
HEALTHCHECK --interval=10s --timeout=5s --retries=3 CMD curl --fail http://localhost/cgi-bin/list_s3_contents.sh || exit 1

# To run apache2 in the background
CMD /usr/sbin/apache2ctl -D FOREGROUND
