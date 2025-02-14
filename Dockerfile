## Copyright (c) 2021, Oracle and/or its affiliates.
ARG BASE_IMAGE=oraclelinux:8
FROM ${BASE_IMAGE}

LABEL maintainer="Stephen Balousek <stephen.balousek@oracle.com>"

ARG INSTALLER
RUN : ${INSTALLER:?}

# Default user and group for OGG
ARG OGG_USER=ogg
ARG OGG_GROUP=ogg
ARG OGG_UID=1001880000
ARG OGG_GID=1001880000

# Environment variables
ENV OGG_HOME=/u01/ogg
ENV OGG_DEPLOYMENT_HOME=/u02
ENV OGG_TEMPORARY_FILES=/u03
ENV OGG_DEPLOYMENT_SCRIPTS=/u01/ogg/scripts
ENV PATH="${OGG_HOME}/bin:${PATH}"
ENV OGG_USER=${OGG_USER}
ENV OGG_GROUP=${OGG_GROUP}

# Copy installation scripts and installer
COPY install-*.sh /tmp/
COPY ${INSTALLER} /tmp/installer.zip
COPY bin/ /usr/local/bin/

# Install dependencies and create the OGG user and group
RUN yum update -y && \
    yum install -y shadow-utils && \
    yum clean all && \
    groupadd -g ${OGG_GID} ${OGG_GROUP} && \
    useradd -m -u ${OGG_UID} -g ${OGG_GROUP} -s /bin/bash ${OGG_USER}

# Run installation scripts as root
RUN bash -c "/tmp/install-prerequisites.sh" && \
    bash -c "/tmp/install-deployment.sh" && \
    rm -fr /tmp/* /etc/nginx

# Copy NGINX configuration
COPY nginx/ /etc/nginx/

# Expose ports
EXPOSE 80 443

# Define volumes
VOLUME [ "${OGG_DEPLOYMENT_HOME}", "${OGG_TEMPORARY_FILES}", "${OGG_DEPLOYMENT_SCRIPTS}" ]

# Fix ownership for volumes
RUN mkdir -p /u02 /u03 && \
    chown -R ${OGG_UID}:${OGG_GID} /u02 /u03 && \
    chmod -R 775 /u02 /u03

# Set correct permissions for deployment script
RUN chmod +x /usr/local/bin/deployment-main.sh

# Healthcheck
HEALTHCHECK --start-period=90s --interval=30s --retries=3 \
    CMD [ "/usr/local/bin/healthcheck" ]

# Use the OGG user instead of hardcoded UID
#USER ${OGG_USER}

# Entrypoint
ENTRYPOINT [ "/usr/local/bin/deployment-main.sh" ]