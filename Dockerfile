FROM centos:centos6
MAINTAINER r2h2 <rainer@hoerbe.at>

RUN yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm -y
# CentOS7
#RUN yum -y install epel-release
RUN yum install usbutils nano wget unzip gcc gcc-c++ redhat-lsb-core opensc pcsc-lite python-pip python-devel libxslt-devel -y


# === install pyFF
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

# === install Safenet Client
#RUN yum -y install xorg-x11-apps
#RUN mkdir -p /opt/sac/
#COPY mgmt_sys/lib/safenet/Linux/Installation/Core/RPM/x64/SafenetAuthenticationClient-core-9.0.43-0.x86_64.rpm /opt/sac/SafenetAuthenticationClient-core.rpm
#RUN rpm -i /opt/sac/SafenetAuthenticationClient-core.rpm --nodeps
#ADD mgmt_sys/lib/safenet/Linux/Installation/Standard/RPM/x64/SafenetAuthenticationClient-9.0.43-0.x86_64.rpm /opt/sac/
#RUN rpm -i /opt/sac/SafenetAuthenticationClient-9.0.43-0.x86_64.rpm --nodeps

# pyff is based on py2.x, but PVZD/PIP on py3.4 (rh scl only has py3.3)


# If using this file to do a manual, non-docker install, then use this:
# systemctl enable  pcscd.service
# systemctl start  pcscd.service

COPY opt /opt


# === install PEP
# CentOS 7: preferring EPEL over redhat-scl and ius:
# RUN yum -y install python34

# CentOS 6: IUS
RUN yum -y install https://centos6.iuscommunity.org/ius-release.rpm
RUN yum -y install python34u-devel

# RHEL 6: SCL

# install required packages from pypi
RUN yum -y install libffi-devel openssl-devel
RUN pip3.4 install -r opt/PVZDpolman/PolicyManager/requirements.txt

# install dependent packages from other sources
RUN cd opt/PYZDpolman/dependent_pkg
RUN cd json2html && python3.4 setup.py install && cd ..
RUN cd pyjnius && python3.4 setup.py install && cd ..
RUN cd ordereddict* && python3.4 setup.py install && cd ../../..

RUN echo "export JAVA_HOME=/etc/alternatives/java_sdk_1.8.0" >> ~/.bashrc
RUN echo "export JDK_HOME=/etc/alternatives/java_sdk_1.8.0" >> ~/.bashrc
RUN echo "export JRE_HOME=/etc/alternatives/java_sdk_1.8.0/jre" >> ~/.bashrc



