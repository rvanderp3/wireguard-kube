FROM quay.io/centos/centos:stream8

USER 0
RUN dnf install -y epel-release
RUN dnf install -y wireguard-tools net-tools gettext git wget make
RUN git clone https://github.com/WireGuard/wireguard-go.git
RUN wget https://go.dev/dl/go1.20.5.linux-amd64.tar.gz
RUN tar -C /usr/local -xf go1.20.5.linux-amd64.tar.gz
ENV PATH="$PATH::/usr/local/go/bin"
RUN cd wireguard-go && make
RUN cp wireguard-go/wireguard-go /usr/local/bin
COPY entrypoint.sh /usr/local/bin
CMD /usr/local/bin/entrypoint.sh
