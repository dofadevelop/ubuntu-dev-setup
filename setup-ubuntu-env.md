# Ubuntu 개발 환경 설정

## 1. TMUX

```bash
sudo apt-get -y install tmux
```

**`~/.tmux.conf` 설정:**

```bash
# 패널 나누기
unbind %
bind h split-window -h

unbind '"'
bind v split-window -v

set -g base-index 1
setw -g pane-base-index 1
```

설정 적용:

```bash
tmux source-file ~/.tmux.conf
```

---

## 2. tig

```bash
sudo apt-get install -y tig
```

---

## 3. fd-find

```bash
sudo apt-get install -y fd-find
```

---

## 4. fzf

> 참고: https://github.com/junegunn/fzf?tab=readme-ov-file#installation

```bash
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
```

---

## 5. ripgrep

```bash
sudo apt install -y ripgrep
```

---

## 6. ctags

```bash
sudo apt install -y universal-ctags
```

---

## 7. Neovim

```bash
sudo apt-get update
sudo apt-get install neovim
```

Neovim은 파이썬 모듈을 요구한다. 파이썬 관련 패키지를 설치하자.

```bash
sudo apt-get install python-dev-is-python3 python3-pip python3-dev
```

> `nvim` 명령으로 Neovim을 실행할 수 있다.

**설정 파일 생성** (`~/.config/nvim/init.vim`):

```bash
mkdir -p ~/.config/nvim
touch ~/.config/nvim/init.vim
```

**vim-plug 설치:**

```bash
sudo apt install curl
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

**설정 파일 복사:**

```bash
cp neovim/init.vim ~/.config/nvim/init.vim
```

---

## 8. Node.js 설치

```bash
curl -sL https://install-node.now.sh/lts | sudo bash
```

---

## 9. Yarn 설치

```bash
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update
sudo apt install -y yarn
```

---

## 10. nvim PlugInstall

```bash
nvim +PlugInstall
cd ~/.config/nvim/plugged/coc.nvim; yarn install
```

---

## 11. Airline 폰트 깨질 때

```bash
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts

wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip JetBrainsMono.zip
fc-cache -fv
```

> 설치 후 재부팅 필요
