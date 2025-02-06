# Ensure directories exist before changing ownership
RUN groupmod -g 1001880000 ogg && \
    usermod -u 1001880000 -g 1001880000 ogg && \
    mkdir -p ${OGG_DEPLOYMENT_HOME} ${OGG_TEMPORARY_FILES} ${OGG_DEPLOYMENT_SCRIPTS} ${OGG_HOME} && \
    chown -R 1001880000:1001880000 ${OGG_DEPLOYMENT_HOME} ${OGG_TEMPORARY_FILES} ${OGG_DEPLOYMENT_SCRIPTS} ${OGG_HOME}