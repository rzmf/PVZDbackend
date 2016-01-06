FROM centos:centos6
MAINTAINER r2h2 <rainer@hoerbe.at>

RUN yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm -y
RUN yum install usbutils nano wget unzip gcc gcc-c++ redhat-lsb-core opensc pcsc-lite python-pip python-devel libxslt-devel -y
RUN pip install --upgrade pip
#using iso8601 0.1.9 because of str/int compare bug in pyff
RUN pip install six
RUN easy_install --upgrade six
#use easy_install solves install bug
RUN pip install importlib
RUN pip install iso8601==0.1.9
RUN pip install pyff
#using pykcs11 1.3.0 because of missing wrapper in v 1.3.1
RUN pip install pykcs11==1.3.0
RUN mkdir /opt/sac/
RUN wget http://files.hoerbe.at/daunlod/SafeNetAuthenticationClient_Linux_8.1.zip -P /opt/sac/
RUN unzip /opt/sac/SafeNetAuthenticationClient_Linux_8.1.zip -d /opt/sac/
RUN unzip /opt/sac/SAC\ 8.1\ Linux/x86_64/SAC_8_1_0_4_Linux_RPM_64.zip -d /opt/sac/
RUN rpm -i /opt/sac/SAC_8_1_0_4_Linux_RPM_64/RPM/SafenetAuthenticationClient-8.1.0-4.x86_64.rpm --nodeps
RUN mkdir /opt/sac/tests
RUN touch  /opt/sac/tests/init-test.sh
RUN echo '#!/bin/sh' > /opt/sac/tests/init-test.sh
RUN echo 'echo ***Initializing Token***' >> /opt/sac/tests/init-test.sh
RUN echo 'pkcs11-tool --module /usr/lib64/libeToken.so --init-token --label test --pin secret1 --so-pin secret2 || exit -1'  >> /opt/sac/tests/init-test.sh
RUN echo 'echo ***Initializing User PIN***' >> /opt/sac/tests/init-test.sh
RUN echo 'pkcs11-tool --module /usr/lib64/libeToken.so -l --init-pin --pin secret1 --so-pin secret2' >> /opt/sac/tests/init-test.sh
RUN echo 'echo ***Generating RSA key***' >> /opt/sac/tests/init-test.sh
RUN echo 'pkcs11-tool --module /usr/lib64/libeToken.so -l -k --key-type rsa:2048 -d 1 --label test --pin secret1 || exit -1' >> /opt/sac/tests/init-test.sh
RUN echo 'echo ***Checking objects on eToken***' >> /opt/sac/tests/init-test.sh
RUN echo 'pkcs11-tool --module /usr/lib64/libeToken.so -l -O --pin secret1 || exit -1' >> /opt/sac/tests/init-test.sh
RUN echo 'echo ***Testing with pyFF***' >> /opt/sac/tests/init-test.sh
RUN echo 'echo ****XML from hoerbe.at****' >> /opt/sac/tests/init-test.sh
RUN echo 'pyff /opt/sac/tests/test-yaml' >> /opt/sac/tests/init-test.sh
RUN echo 'echo ***Testing with pyFF***' >> /opt/sac/tests/init-test.sh
RUN echo 'echo ****XML from swamid.se****' >> /opt/sac/tests/init-test.sh
RUN echo 'pyff /opt/sac/tests/test-swamid-yaml' >> /opt/sac/tests/init-test.sh
RUN chmod +x /opt/sac/tests/init-test.sh
RUN touch /opt/sac/tests/start-services.sh
RUN echo '#!/bin/sh' > /opt/sac/tests/start-services.sh
RUN echo '/bin/dbus-daemon --system || exit -1' >> /opt/sac/tests/start-services.sh
RUN echo '/usr/sbin/hald --daemon=yes || exit -1' >> /opt/sac/tests/start-services.sh
RUN echo '/usr/sbin/pcscd -c /etc/reader.conf || exit -1' >> /opt/sac/tests/start-services.sh
RUN chmod +x /opt/sac/tests/start-services.sh
RUN touch /opt/sac/tests/test-yaml
RUN echo '- load:' > /opt/sac/tests/test-yaml
RUN echo '   - http://files.hoerbe.at/daunlod/idpExampleOrg.xml' >> /opt/sac/tests/test-yaml
RUN echo '- select: "!//md:EntityDescriptor[md:IDPSSODescriptor]"' >> /opt/sac/tests/test-yaml
RUN echo '- xslt:' >> /opt/sac/tests/test-yaml
RUN echo '    stylesheet: tidy.xsl' >> /opt/sac/tests/test-yaml
RUN echo '- sign:'  >> /opt/sac/tests/test-yaml
RUN echo '    key: pkcs11:///usr/lib64/libeToken.so/test' >> /opt/sac/tests/test-yaml
RUN echo '- publish: /tmp/idp.xml' >> /opt/sac/tests/test-yaml
RUN echo '- stats' >> /opt/sac/tests/test-yaml
RUN touch /opt/sac/tests/test-swamid-yaml
RUN echo '- load:' > /opt/sac/tests/test-swamid-yaml
RUN echo '   - http://md.swamid.se/md/swamid-2.0.xml 12:60:D7:09:6A:D9:C1:43:AD:31:88:14:3C:A8:C4:B7:33:8A:4F:CB' >> opt/sac/tests/test-swamid-yaml
RUN echo '- select: "!//md:EntityDescriptor[md:IDPSSODescriptor]"' >> /opt/sac/tests/test-swamid-yaml
RUN echo '- xslt:' >> /opt/sac/tests/test-swamid-yaml
RUN echo '    stylesheet: tidy.xsl' >> /opt/sac/tests/test-swamid-yaml
RUN echo '- sign:'  >> /opt/sac/tests/test-swamid-yaml
RUN echo '    key: pkcs11:///usr/lib64/libeToken.so/test' >> /opt/sac/tests/test-swamid-yaml
RUN echo '- publish: /tmp/idp.xml' >> /opt/sac/tests/test-swamid-yaml
RUN echo '- stats' >> /opt/sac/tests/test-swamid-yaml

#Caution PYKCS11PIN is PLAIN!!
ENV PYKCS11PIN=secret1
