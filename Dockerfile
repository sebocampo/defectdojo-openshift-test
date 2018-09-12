FROM ubuntu:16.04
MAINTAINER Igor Bakalo <bigorigor.ua@gmail.com>

# Setup application environment variables

ARG DBTYPE="1"
ARG SQLHOST=""
ARG SQLPORT=""
ARG SQLUSER=""
ARG SQLPWD=""
ARG DBNAME=""
ARG APPFQDN=""
ARG DOJO_ADMIN_PASSWORD=""

ENV DBTYPE=$DBTYPE
ENV SQLHOST=$SQLHOST
ENV SQLPORT=$SQLPORT
ENV SQLUSER=$SQLUSER
ENV SQLPWD=$SQLPWD
ENV DBNAME=$DBNAME
ENV APPFQDN=$APPFQDN
ENV DOJO_ADMIN_PASSWORD=$DOJO_ADMIN_PASSWORD

# Update and install basic requirements;
RUN apt-get update && apt-get install -y \
    python \
    python-pip \
    apt-transport-https \
    nodejs-legacy \
    npm \
    mysql-client \
    sudo \
    curl \
    git \
    expect \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install virtualenv
RUN pip install virtualenv

# Create application user
RUN adduser --disabled-password --gecos "DefectDojo" dojo

# Upload The DefectDojo application
WORKDIR /opt
RUN git clone https://github.com/DefectDojo/django-DefectDojo.git

# Install application dependancies
WORKDIR /opt/django-DefectDojo
RUN chmod 0770 -R /opt/django-DefectDojo
RUN chown dojo -R /opt/django-DefectDojo
RUN /bin/bash -c "cd /opt/django-DefectDojo && source entrypoint_scripts/common/dojo-shared-resources.sh -y && install_os_dependencies"

# Give the app user sudo permissions and switch executing user
RUN echo "dojo    ALL=(ALL:ALL)   NOPASSWD: ALL" > /etc/sudoers.d/sudo_dojo

# Add entrypoint
COPY entrypoint.sh /
RUN chmod 0660 /entrypoint.sh \
    && chmod a+x /entrypoint.sh

# Set arbitrary user permissions on passwd file
RUN chmod g=u /etc/passwd

USER dojo:dojo

ENTRYPOINT ["/entrypoint.sh"]
