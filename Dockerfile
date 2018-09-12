FROM osem/base
ARG CONTAINER_USERID

# Configure our user
RUN usermod -u $CONTAINER_USERID osem

USER osem
WORKDIR /osem/

CMD ["/osem/bin/osem-init.sh"]

