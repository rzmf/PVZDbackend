FROM centos:centos6
MAINTAINER r2h2 <rainer@hoerbe.at>

RUN yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm -y
RUN yum install usbutils nano wget unzip gcc gcc-c++ redhat-lsb-core opensc pcsc-lite python-pip python-devel libxslt-devel -y
# TODO: install python 2.7 from SCL. Reason: pip install of pyXMLSecurity failed
#       -> need virtualenv
RUN pip install --upgrade pip
RUN pip install six
#use easy_install solves install bug
# InsecurePlatformWarning can be ignored - this system does not use TLS
RUN easy_install --upgrade six
RUN pip install importlib
#using iso8601 0.1.9 because of str/int compare bug in pyff
RUN pip install iso8601==0.1.9
RUN pip install pyff
#using pykcs11 1.3.0 because of missing wrapper in v 1.3.1
RUN pip install pykcs11==1.3.0

RUN yum -y install xorg-x11-apps
RUN mkdir -p /opt/sac/
ADD mgmt_sys/lib/safenet/Linux/Installation/Core/RPM/x64/SafenetAuthenticationClient-core-9.0.43-0.x86_64.rpm /opt/sac/SafenetAuthenticationClient-core.rpm
RUN rpm -i /opt/sac/SafenetAuthenticationClient-core.rpm --nodeps
#ADD mgmt_sys/lib/safenet/Linux/Installation/Standard/RPM/x64/SafenetAuthenticationClient-9.0.43-0.x86_64.rpm /opt/sac/
#RUN rpm -i /opt/sac/SafenetAuthenticationClient-9.0.43-0.x86_64.rpm --nodeps

RUN mkdir -p /opt/sac/tests
ADD resource/init-test.sh /opt/sac/tests/
ADD resource/start-service.sh /opt/sac/tests/
ADD resource/test-yaml /opt/sac/tests/
ADD resource/test-swamid-yaml /opt/sac/tests/

# pyff is based on py2.x, but PVZD/PIP on py3.4 (rh scl only has py3.3)

RUN yum -y install https://centos6.iuscommunity.org/ius-release.rpm
RUN yum -y install python34u

#RUN systemctl enable  pcscd.service
#RUN systemctl start  pcscd.service


# create SW-certificate for test of pyff:
