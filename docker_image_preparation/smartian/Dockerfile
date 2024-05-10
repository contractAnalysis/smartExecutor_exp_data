FROM ubuntu:18.04


### Install packages and utilities

# You may replace the URL for into a faster one in your region.
# RUN sed -i 's/archive.ubuntu.com/ftp.daumkakao.com/g' /etc/apt/sources.list
ENV DEBIAN_FRONTEND="noninteractive"

RUN apt-get update && \
    apt-get -yy install \
      wget apt-transport-https git unzip \
      build-essential libtool libtool-bin gdb \
      automake autoconf bison flex python sudo vim \
      curl software-properties-common \
      python3 python3-pip libssl-dev pkg-config \
      libsqlite3-0 libsqlite3-dev apt-utils locales \
      python-pip-whl libleveldb-dev python3-setuptools \
      python3-dev pandoc python3-venv \
      libgmp-dev libbz2-dev libreadline-dev libsecp256k1-dev locales-all

# Install .NET Core
RUN wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    apt-get update && apt-get -yy install dotnet-sdk-5.0 && \
    rm -f packages-microsoft-prod.deb
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1

# Install Solidity compiler
WORKDIR /usr/bin
RUN wget https://github.com/ethereum/solidity/releases/download/v0.4.25/solc-static-linux
RUN mv solc-static-linux solc
RUN chmod +x solc

RUN mkdir /home/smartian/

# Install Smartian
RUN cd /home/smartian/ && \
    git clone https://github.com/SoftSec-KAIST/Smartian.git && \
    cd Smartian && \
    #git checkout v1.0 && \
    git checkout runtime-coverage && \
    git submodule update --init --recursive && \
    make


CMD ["/bin/bash"]
