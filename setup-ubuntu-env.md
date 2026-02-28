1. TMUX

```bash
sudo apt-get -y install tmux
```

- ~/.tmux.conf
    ```bash
    # 패널 나누기
    unbind %
    bind h split-window -h

    unbind '"'
    bind v split-window -v

    set -g base-index 1
    setw -g pane-base-index 1
    ```

tmux source-file ~/.tmux.conf

2. tig

```bash
sudo apt-get install -y tig
```

3. fd-find
```bash
sudo apt-get install -y fd-find
```

4. fzf

ref : https://github.com/junegunn/fzf?tab=readme-ov-file#installation

```bash
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
```

5. ripgrep

```bash
sudo apt install -y ripgrep
```

6. ctags

```bash
sudo apt install -y universal-ctags
```


7. neovim
neovim을 설치한다.

```bash
~~sudo add-apt-repository ppa:neovim-ppa/stable~~
sudo apt-get update
sudo apt-get install neovim
```

neovim은 파이선모듈을 요구한다. 파이선 관련 패키지를 설치하자.

```bash
sudo apt-get install python-dev-is-python3 python3-pip python3-dev
```

nvim으로 neovim을 실행 할 수 있다.

NeoVim 설정파일의 위치는 ~/.config/nvim/init.vim이다. 설정내용은 vim과 차이가 없다.

```
mkdir -p ~/.config/nvim
touch ~/.config/nvim/init.vim
```

**Install vim-plug:**

```bash
sudo apt  install curl
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

```bash
cp neovim/init.vim ~/.config/nvim/init.vim
```

8. nodejs 설치

```bash
curl -sL https://install-node.now.sh/lts | sudo bash
```

9. yarn 설치
```bash
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update
sudo apt install -y yarn
```

10. nvim plugInstall
```bash
nvim +PlugInstall
cd ~/.config/nvim/plugged/coc.nvim; yarn install
```

11. airline font 깨질때
```bash
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts

wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip JetBrainsMono.zip
fc-cache -fv
```
재부팅
