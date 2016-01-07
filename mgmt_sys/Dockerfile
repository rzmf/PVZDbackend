FROM centos:centos7
MAINTAINER r2h2 <rainer@hoerbe.at>

RUN yum -y groupinstall "Development Tools" "GNOME Desktop" net-tools
# boot into GNOME
RUN ln -sf /lib/systemd/system/runlevel5.target /etc/systemd/system/default.target

RUN mkdir -p /opt/sac/
ADD lib/safenet/Linux /opt/sac/
RUN rpm -i /opt/sac/Linux/Installation/Standard/RPM/x64/SafenetAuthenticationClient-9.0.43-0.x86_64.rpm




