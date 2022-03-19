FROM ubuntu:20.04
LABEL maintainer="tangrui.tory"

# setting locale
ENV LANG en_US.UTF-8

# color env
ENV COLORTERM truecolor
ENV TERM xterm-256color

# timezone
ARG TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# user root
USER root
RUN echo 'root:root' | chpasswd

# install common utls
RUN apt-get update && apt-get install -y \
    sudo\
    zsh \
    vim \
    wget \
    curl \
    python \
    python3-distutils \
    thefuck \
    git-core \
    locales \
    lsof \
    iputils-ping

#  install oh-my-zsh and some plugin
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
    && sed -i 's/^plugins=(/plugins=(sudo zsh-autosuggestions zsh-syntax-highlighting z /' ~/.zshrc \
    && chsh -s /bin/zsh

# add user me
RUN useradd --create-home --no-log-init --shell /bin/zsh -G sudo me 
RUN adduser me sudo
RUN echo 'me:me' | chpasswd

USER me

# change locale to utf-8
RUN echo "me" | sudo -S locale-gen en_US.UTF-8 \
    && sudo update-locale LANG=en_US.UTF-8

# install omz for me
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
    && sed -i 's/^plugins=(/plugins=(sudo zsh-autosuggestions zsh-syntax-highlighting z /' ~/.zshrc

# install zsh theme: powerlevel10k
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k \
    && echo "source ~/powerlevel10k/powerlevel10k.zsh-theme" >> ~/.zshrc

# add thefuck alia
RUN echo "# thefuck alias" >> ~/.zshrc \
    && echo "eval \$(thefuck --alias)" >> ~/.zshrc

# install nvm and node
ARG NVM_DIR=/home/me/.nvm
ARG NODE_VERSION=v16
RUN mkdir -p $NVM_DIR && \
    curl -o- https://gitee.com/mirrors/nvm/raw/master/install.sh | bash \
        && . $NVM_DIR/nvm.sh \
        && nvm install ${NODE_VERSION} \
        && nvm use ${NODE_VERSION} \
        && nvm alias ${NODE_VERSION} \
        && ln -s `npm bin --global` /home/me/.node-bin \
        && npm install --global nrm

RUN echo '' >> ~/.zshrc \
    && echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.zshrc \
    && echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm' >> ~/.zshrc

# install yarn
RUN curl -o- -L https://yarnpkg.com/install.sh | bash; \
    echo '' >> ~/.zshrc && \
    echo 'export PATH="$HOME/.yarn/bin:$PATH"' >> ~/.zshrc

# Add NVM binaries to root's .bashrc
USER root

RUN echo '' >> ~/.zshrc \
    && echo 'export NVM_DIR="/home/me/.nvm"' >> ~/.zshrc \
    && echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm' >> ~/.zshrc

RUN echo '' >> ~/.zshrc \
    && echo 'export YARN_DIR="/home/me/.yarn"' >> ~/.zshrc \
    && echo 'export PATH="$YARN_DIR/bin:$PATH"' >> ~/.zshrc

# delete apt/lists to minus final image size. see：https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#general-guidelines-and-recommendations
RUN rm -rf /var/lib/apt/lists/*

WORKDIR /home/me