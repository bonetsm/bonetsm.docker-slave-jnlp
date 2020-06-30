# The MIT License
#
#  Copyright (c) 2015-2017, CloudBees, Inc.
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in
#  all copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#  THE SOFTWARE.

ARG version=alpine
FROM jenkins/agent:$version

ARG version
LABEL Description="This is a base image, which allows connecting Jenkins agents via JNLP protocols" Vendor="Jenkins project" Version="$version"

ARG user=jenkins

USER root
COPY jenkins-agent /usr/local/bin/jenkins-agent
RUN chmod +x /usr/local/bin/jenkins-agent &&\
    ln -s /usr/local/bin/jenkins-agent /usr/local/bin/jenkins-slave &&\
    sed -i s/^http/#http/g /etc/apk/repositories &&\
    echo http://dl-cdn.alpinelinux.org/alpine/latest-stable/main | tee -a /etc/apk/repositories &&\
    echo http://dl-cdn.alpinelinux.org/alpine/latest-stable/community | tee -a /etc/apk/repositories &&\
    apk upgrade --update-cache --available &&\
    apk add python3 ansible ansible-lint sshpass py3-pip sudo iputils &&\
    /usr/bin/pip3 install yamllint &&\
    echo "jenkins ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/jenkins &&\
    rm -rf /var/cache/apk/*&&\
    mkdir /tmp/tf &&\
    cd /tmp/tf &&\
    wget https://releases.hashicorp.com/terraform/0.12.26/terraform_0.12.26_linux_amd64.zip &&\
    unzip terraform_0.12.26_linux_amd64.zip &&\
    mv terraform /usr/local/bin &&\
    cd / &&\
    rm -rf /tmp/tf &&\
    terraform init
USER ${user}

ENTRYPOINT ["jenkins-agent"]
