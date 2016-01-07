FROM centos:centos6
MAINTAINER r2h2 <rainer@hoerbe.at>

RUN yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm -y
RUN yum install usbutils nano wget unzip gcc gcc-c++ redhat-lsb-core opensc pcsc-lite python-pip python-devel libxslt-devel -y
RUN pip install --upgrade pip
RUN pip install six
#use easy_install solves install bug
RUN easy_install --upgrade six
RUN pip install importlib
#using iso8601 0.1.9 because of str/int compare bug in pyff
RUN pip install iso8601==0.1.9
RUN pip install pyff
#using pykcs11 1.3.0 because of missing wrapper in v 1.3.1
RUN pip install pykcs11==1.3.0

RUN mkdir -p /opt/sac/
ADD mgmt_sys/lib/safenet/Linux /opt/sac/
RUN rpm -i /opt/sac/Linux/Installation/Standard/RPM/x64SafenetAuthenticationClient-core-9.0.43-0.x86_64.rpm

RUN mkdir -p /opt/sac/tests
ADD resource/init-test.sh /opt/sac/tests/
ADD resource/start-service.sh /opt/sac/tests/
ADD resource/test-yaml /opt/sac/tests/
ADD resource/test-swamid-yaml /opt/sac/tests/

# pyff is based on py2.x, but PVZD/PIP on py3.4
RUN yum -y install scl-utils
# Centos7 for RHEL see https://www.softwarecollections.org/en/scls/rhscl/rh-python34/
RUN yum -y centos-release-scl-rh
RUN yum -y install rhscl-rh-python34-*.noarch.rpm
RUN yum -y install rh-python34
RUN scl enable rh-python34 bash