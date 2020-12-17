FROM archlinux

# base-devel needed for installing python from pyenv.
RUN pacman -Syu --noconfirm --needed archlinux-keyring sudo git base-devel

# Setup pyenv as root user.
WORKDIR /root
RUN git clone git://github.com/yyuu/pyenv.git .pyenv
ENV HOME /root
ENV PYENV_ROOT $HOME/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH

RUN pyenv install 3.9.0
RUN pyenv global 3.9.0
RUN pyenv rehash

RUN pip install robotframework

