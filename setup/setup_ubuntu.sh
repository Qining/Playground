#!/usr/bin/env sh

exe() { echo "\$ $@"; "$@"; }

SCRIPT_DIR="$( cd "$( dirname "${BASE_SOURCE[0]}" )" && pwd)"
me=`basename "$0"`
trap 'echo Ctrl-c, ${me} interrupted; exit' INT
echo "${me} -- Start"

# basic
sudo apt update
sudo apt install -y curl

if [ -f $HOME/.inputrc ]; then
	echo "$include ${SCRIPT_DIR}/ubuntu_inputrc" >> $HOME/.inputrc
else
	cp ${SCRIPT_DIR}/ubuntu_inputrc $HOME/.inputrc
fi

exec bind -f $HOME/.inputrc

# docker
sudo apt -y install docker.io
exe sudo groupadd docker
exe sudo usermod -aG docker $USER
exe sudo systemctl start docker
exe sude systemctl enable docker

# tmux
sudo apt -y install tmux xsel
if [ -d $HOME/.tmux/plugins/tpm ]; then
	rm -rf $HOME/.tmux/plugins/tpm
fi

exe mkdir -p $HOME/.tmux/plugins
exe git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
exe cp $SCRIPT_DIR/tmux.conf $HOME/.tmux.conf

# vim
sudo apt -y install vim
exe git config --global core.editor.vim
if [ ! -d $HOME/.vim/autoload ]; then
	exe mkdir -p $HOME/.vim/autoload
fi
exe curl -fLo $HOME/.vim/autoload/plug.vim --create-dirs \
	https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
exe cp $SCRIPT_DIR/vimrc $HOME/.vimrc

echo -e \
	"\nInstalling vim plugins...\n"
echo | echo | vim +PlugInstall +qall &>/dev/null

# nordvpn
exe wget -qnc https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/nordvpn-release_1.0.0_all.deb -P /tmp
sudo dpkg -i /tmp/nordvpn-release_1.0.0_all.deb
sudo apt update
sudo apt install nordvpn
