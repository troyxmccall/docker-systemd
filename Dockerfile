FROM ubuntu:22.04

ENV container docker

# Installing systemd and other utilities. Removing unnecessary systemd services to reduce overhead and potential issues.
RUN apt-get update && \
    apt-get install -y \
    init dbus systemd iproute2 gpg && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    find /etc/systemd/system \
    /lib/systemd/system \
    -path '*.wants/*' \
    -not -name '*journald*' \
    -not -name '*systemd-tmpfiles*' \
    -not -name '*systemd-user-sessions*' \
    -exec rm \{} \; && \
    systemctl set-default multi-user.target && \
    systemctl mask \
    dev-hugepages.mount \
    sys-fs-fuse-connections.mount \
    tmp.mount

# Disabling services that may cause issues within a container context.
RUN find /etc/systemd/system /lib/systemd/system -path '*.wants/*' -exec rm \{} \+ && \
    rm -f /lib/systemd/system/multi-user.target.wants/* && \
    rm -f /etc/systemd/system/*.wants/* && \
    rm -f /lib/systemd/system/local-fs.target.wants/* && \
    rm -f /lib/systemd/system/sockets.target.wants/*udev* && \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl* && \
    rm -f /lib/systemd/system/basic.target.wants/* &&\
    rm -f /lib/systemd/system/anaconda.target.wants/* && \
    rm -f /lib/systemd/system/plymouth* && \
    rm -f /lib/systemd/system/systemd-update-utmp*

# Adjusting systemd for Docker.
RUN systemctl mask \
    systemd-remount-fs.service \
    getty.target \
    console-getty.service \
    getty-static.service \
    getty@tty1.service \
    systemd-logind.service \
    autovt@.service \
    systemd-udevd.service \
    systemd-udevd.socket && \
    systemctl disable systemd-resolved.service && \
    rm -f /lib/systemd/system/systemd*udev* && \
    rm -f /lib/systemd/system/getty.target

COPY setup /sbin/

CMD ["/sbin/init"]
