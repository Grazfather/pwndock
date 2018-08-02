FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt update \
    && apt -y install locales
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# base tools
RUN apt update \
    && apt -y install vim patchelf netcat socat strace ltrace curl wget git gdb \
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

# fix rop gadget
RUN python -m pip install capstone==3.0.5rc2

# libc6-dbg
RUN dpkg --add-architecture i386 \
    && apt update \
    && apt -y install libc6-dbg libc6-dbg:i386 glibc-source \
    && apt clean \
    && tar -C /usr/src/glibc/ -xvf /usr/src/glibc/glibc-*.tar.xz

# pwntools
RUN apt update \
    && apt -y install python-pip python-dev sudo locales \
    && apt clean
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

# GEF
RUN cd ~ \
    && git clone https://github.com/hugsy/gef.git \
    && echo "source ~/gef/gef.py > ~/.gdbinit"

# Install dotfiles
RUN cd ~ \
    && git clone https://github.com/Grazfather/dotfiles.git \
    && bash ~/dotfiles/init.sh

# work env
WORKDIR /code
