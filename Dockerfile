FROM centos:centos7
MAINTAINER r2h2 <rainer@hoerbe.at>

# RHEL6
#RUN yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm -y
# CentOS7
RUN yum -y install epel-release \
 && yum -y install curl gcc gcc-c++ git nano unzip wget which \
 && yum -y install redhat-lsb-core opensc pcsc-lite usbutils \
 && yum -y install python-pip python-devel libxslt-devel


# == install pyFF using py2.6 or 2.7
RUN pip install --upgrade pip \
 && pip install six
# use easy_install solves install bug
# InsecurePlatformWarning can be ignored - this system does not use TLS
RUN easy_install --upgrade six \
 && pip install importlib
#using iso8601 0.1.9 because of str/int compare bug in pyff
RUN pip install iso8601==0.1.9 \
 && pip install pyff
#using pykcs11 1.3.0 because of missing wrapper in v 1.3.1
RUN pip install pykcs11==1.3.0


# If using this file to do a manual, non-docker install, then use this:
# systemctl enable  pcscd.service
# systemctl start  pcscd.service

COPY opt /opt

# == install PEP
RUN yum -y install java-1.8.0-openjdk-devel.x86_64
ENV JAVA_HOME=/etc/alternatives/java_sdk_1.8.0

# PVZD/PIP requires py==3.4
# CentOS 7: EPEL does contain pyhton 3.4, but it fails to install PIP -> extra download
RUN yum -y install python34-devel \
 && curl https://bootstrap.pypa.io/get-pip.py | python3.4

# === install required packages from pypi
# virtualenv helps pyjnius not to get confused with py27/34 (otherwise causing "No module named 'jnius.jnius'")
RUN yum -y install libffi-devel openssl-devel \
 && pip3.4 install virtualenv \
 && mkdir /root/virtualenv \
 && (cd /root/virtualenv && virtualenv --system-site-packages pvzd34) \
 && source /root/virtualenv/pvzd34/bin/activate \
 && pip3.4 install -r opt/PVZDpolman/PolicyManager/requirements.txt
# install dependent packages from other sources
WORKDIR /opt/PVZDpolman/dependent_pkg/json2html
RUN python3.4 setup.py install && cd ..  # only required for PMP
#RUN cd ordereddict* && python3.4 setup.py install && cd ../../.. # only for json2html
WORKDIR /opt/PVZDpolman/dependent_pkg/pyjnius
RUN source /root/virtualenv/pvzd34/bin/activate \
 && (JDK_HOME=$JAVA_HOME; JRE_HOME=$JAVA_HOME/jre; python3.4 setup.py install) \
 && curl -O http://mirror.klaus-uwe.me/apache/ant/binaries/apache-ant-1.9.6-bin.zip \
 && unzip apache-ant-1.9.6-bin.zip \
 && mv apache-ant-1.9.6 /opt/ant \
 && ln -s /opt/ant/bin/ant /usr/local/bin/ant \
 && (ANT_HOME=/opt/ant; make)

# == install git repo
ARG USERNAME=backend
ARG UID=3000
RUN groupadd --gid $UID $USERNAME \
 && useradd --gid $UID --uid $UID $USERNAME \
 && chown $USERNAME:$USERNAME /run \
 && mkdir -p /var/lib/git /var/log/pyff /var/log/pvzd \
 && chown -R $USERNAME:$USERNAME /opt /var/lib/git /var/log/pyff /var/log/pvzd

# === startup backend system
USER $USERNAME
CMD ["/usr/local/bin/backendd"]
