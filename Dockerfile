FROM golang:1.15-buster AS golang
FROM ubuntu:18.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt update \
    && apt -y install locales
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# create tools directory
RUN mkdir ~/tools

# base tools
RUN apt update \
    && apt -y install --no-install-recommends lsof strace ltrace vim patchelf netcat socat file \
    && apt -y install --no-install-recommends curl wget git gdb man sudo inetutils-ping less jq \
    && apt clean

RUN apt update \
    && apt -y install --no-install-recommends python-dev python-pip \
    && apt clean

# Install python3.8
RUN apt -y install --no-install-recommends software-properties-common \
    && add-apt-repository -y ppa:deadsnakes/ppa \
    && apt update \
    && apt -y install python3.8-dev python3.8-venv python3-pip
RUN python3.8 -m venv /root/py38
ENV PATH="/root/py38/bin:${PATH}"

RUN python3 -m pip install --upgrade pip \
    && python2 -m pip install --upgrade pip \
    && python3 -m pip install setuptools \
    && python2 -m pip install setuptools

RUN python2 -m pip install --upgrade pip \
    && python2 -m pip install setuptools
RUN python3 -m pip install --upgrade pwntools

RUN apt update \
    && apt -y install --no-install-recommends gcc-multilib g++-multilib \
    && apt clean

# libc6-dbg & 32-bit libs
RUN dpkg --add-architecture i386 \
    && apt update \
    && apt -y install --no-install-recommends xz-utils libc6-dbg libc6-dbg:i386 glibc-source \
    && apt clean \
    && tar -C /usr/src/glibc/ -xf /usr/src/glibc/glibc-*.tar.xz

# Keystone, Capstone, and Unicorn
RUN apt update \
    && apt -y install --no-install-recommends git cmake gcc g++ pkg-config libglib2.0-dev \
    && apt clean
RUN cd ~/tools \
    && wget https://raw.githubusercontent.com/hugsy/stuff/master/update-trinity.sh \
    && bash ./update-trinity.sh
RUN ldconfig

# Z3
RUN cd ~/tools \
    && git clone --depth 1 https://github.com/Z3Prover/z3.git && cd z3 \
    && python3 scripts/mk_make.py --python \
    && cd build; make && make install

# Angr
RUN python3 -m pip install angr

# pwntools
RUN python -m pip install pwntools
RUN python3 -m pip install --upgrade pwntools

# one_gadget
RUN apt update \
    && apt -y install --no-install-recommends ruby-full \
    && apt clean
RUN gem install one_gadget

# arm_now
RUN python3 -m pip install arm_now

RUN apt update \
    && apt -y install --no-install-recommends e2tools qemu \
    && apt clean

# ARM cross compilers
RUN apt update \
    && apt -y install --no-install-recommends gcc-arm-linux-gnueabihf binutils-arm-linux-gnueabihf g++-arm-linux-gnueabihf \
    && apt clean

# ropper
RUN python3 -m pip install ropper

# Ripgrep
RUN RIPGREP_VERSION=$(curl -s https://api.github.com/repos/BurntSushi/ripgrep/releases/latest | jq -r .tag_name) \
    && curl -LO https://github.com/BurntSushi/ripgrep/releases/download/${RIPGREP_VERSION}/ripgrep_${RIPGREP_VERSION}_amd64.deb \
    && dpkg -i ripgrep_${RIPGREP_VERSION}_amd64.deb \
    && rm ripgrep_${RIPGREP_VERSION}_amd64.deb

# Binwalk
RUN cd ~/tools \
    && git clone --depth 1 https://github.com/devttys0/binwalk && cd binwalk \
    && python3 setup.py install

# Radare2
RUN cd ~/tools \
    && git clone --depth 1 https://github.com/radare/radare2 && cd radare2 \
    && ./sys/install.sh

# Install tmux from source
RUN apt update \
    && apt -y install --no-install-recommends libevent-dev libncurses-dev \
    && apt clean

RUN TMUX_VERSION=$(curl -s https://api.github.com/repos/tmux/tmux/releases/latest | jq -r .tag_name) \
    && wget https://github.com/tmux/tmux/releases/download/$TMUX_VERSION/tmux-$TMUX_VERSION.tar.gz \
    && tar zxf tmux-$TMUX_VERSION.tar.gz \
    && cd tmux-$TMUX_VERSION \
    && ./configure && make && make install \
    && cd .. \
    && rm -rf tmux-$TMUX_VERSION* \
    && echo "tmux hold" | dpkg --set-selections # disable tmux update from apt

# Install Go
COPY --from=golang /usr/local/go /usr/local/go
ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
