FROM ubuntu:16.04

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
    && apt -y install vim patchelf netcat socat strace ltrace curl wget git gdb \
    && apt -y install man sudo inetutils-ping \
    && apt clean

RUN apt update \
    && apt -y install python-dev python-pip \
    && apt -y install python3-dev python3-pip \
    && apt clean

RUN python3 -m pip install --upgrade pip
RUN python -m pip install --upgrade pip

RUN apt update \
    && apt -y install gcc-multilib g++-multilib \
    && apt clean

# libc6-dbg & 32-bit libs
RUN dpkg --add-architecture i386 \
    && apt update \
    && apt -y install libc6-dbg libc6-dbg:i386 glibc-source \
    && apt clean \
    && tar -C /usr/src/glibc/ -xvf /usr/src/glibc/glibc-*.tar.xz

# Keystone, Capstone, and Unicorn
RUN apt -y install git cmake gcc g++ pkg-config libglib2.0-dev
RUN cd ~/tools \
    && wget https://raw.githubusercontent.com/hugsy/stuff/master/update-trinity.sh \
    && bash ./update-trinity.sh
RUN ldconfig

# Z3
RUN cd ~/tools \
    && git clone --depth 1 https://github.com/Z3Prover/z3.git && cd z3 \
    && python scripts/mk_make.py --python \
    && cd build; make && make install

# pwntools
RUN python -m pip install pwntools

# one_gadget
RUN apt update \
    && apt install -y ruby-full \
    && apt clean
RUN gem install one_gadget

# arm_now
RUN python3 -m pip install arm_now

RUN apt update \
    && apt install -y e2tools qemu \
    && apt clean

# ropper
RUN python3 -m pip install ropper

# Ripgrep
RUN curl -LO https://github.com/BurntSushi/ripgrep/releases/download/0.9.0/ripgrep_0.9.0_amd64.deb \
    && dpkg -i ripgrep_0.9.0_amd64.deb \
    && rm ripgrep_0.9.0_amd64.deb

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
    && apt -y install libevent-dev libncurses-dev \
    && apt clean

RUN TMUX_VERSION=$(curl -s https://api.github.com/repos/tmux/tmux/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")') \
    && wget https://github.com/tmux/tmux/releases/download/$TMUX_VERSION/tmux-$TMUX_VERSION.tar.gz \
    && tar zxvf tmux-$TMUX_VERSION.tar.gz \
    && cd tmux-$TMUX_VERSION \
    && ./configure && make && make install \
    && cd .. \
    && rm -rf tmux-$TMUX_VERSION* \
    && echo "tmux hold" | dpkg --set-selections # disable tmux update from apt
