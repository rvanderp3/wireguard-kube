FROM centos

USER 0
RUN dnf install -y epel-release
RUN dnf install -y wireguard-tools net-tools gettext
COPY wireguard-go /usr/local/bin
COPY entrypoint.sh /usr/local/bin
CMD /usr/local/bin/entrypoint.sh
