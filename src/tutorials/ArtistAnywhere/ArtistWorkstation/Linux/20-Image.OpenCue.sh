#!/bin/bash

set -ex

cd /usr/local/bin

grep "centos:7" /etc/os-release && centOS7=true || centOS7=false

if $centOS7; then
    yum -y install gcc
    yum -y install python-devel
    yum -y install epel-release
    yum -y install python-pip
else # CentOS8
    dnf -y install gcc
    dnf -y install python3-devel
fi

fileName="OpenCue-v0.4.95.zip"
downloadUrl="https://bit.blob.core.windows.net/bin/OpenCue/$fileName"
curl -L -o $fileName $downloadUrl/$fileName
unzip $fileName

fileName="opencue-pycue.tar.gz"
tar -xzf $fileName

fileName="opencue-pyoutline.tar.gz"
tar -xzf $fileName

fileName="opencue-admin.tar.gz"
tar -xzf $fileName

fileName="opencue-submit.tar.gz"
tar -xzf $fileName

fileName="opencue-gui.tar.gz"
tar -xzf $fileName

find . -type f -name *.pyc -delete
if $centOS7; then
    pip install --upgrade pip
    pip install --upgrade setuptools
    pip install --requirement "opencue-requirements.txt" --ignore-installed
    pip install --requirement "opencue-requirements-gui.txt"
    cd pycue-*
    python setup.py install
    cd ../pyoutline-*
    python setup.py install
    cd ../cueadmin-*
    python setup.py install
    cd ../cuesubmit-*
    python setup.py install
    cd ../cuegui-*
    python setup.py install
else # CentOS8
    pip3 install --upgrade pip
    pip3 install --upgrade setuptools
    pip3 install --requirement "opencue-requirements.txt" --ignore-installed
    pip3 install --requirement "opencue-requirements-gui.txt"
    cd pycue-*
    python3 setup.py install
    cd ../pyoutline-*
    python3 setup.py install
    cd ../cueadmin-*
    python3 setup.py install
    cd ../cuesubmit-*
    python3 setup.py install
    cd ../cuegui-*
    python3 setup.py install
fi
