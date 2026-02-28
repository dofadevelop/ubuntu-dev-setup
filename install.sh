#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 색상
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

print_step()    { printf "\n${YELLOW}==> %s${RESET}\n" "$*"; }
print_info()    { printf "${CYAN}  -> %s${RESET}\n" "$*"; }
print_success() { printf "${GREEN}  [ok] %s${RESET}\n" "$*"; }
print_error()   { printf "${RED}  [!!] %s${RESET}\n" "$*" >&2; }

trap 'print_error "Line $LINENO에서 실패 (exit code: $?)"' ERR

command_exists() {
    command -v "$1" &>/dev/null
}

apt_install_if_missing() {
    local pkg="$1"
    if dpkg -s "$pkg" &>/dev/null; then
        print_info "$pkg 이미 설치됨, 건너뜀"
    else
        print_info "$pkg 설치 중..."
        sudo apt-get install -y "$pkg"
        print_success "$pkg 설치 완료"
    fi
}

append_if_absent() {
    local source_file="$1"
    local target_file="$2"
    local sentinel="$3"

    if grep -qF "$sentinel" "$target_file" 2>/dev/null; then
        print_info "$(basename "$source_file") 이미 $target_file 에 포함됨, 건너뜀"
    else
        print_info "$target_file 에 $(basename "$source_file") 추가 중..."
        {
            printf '\n# --- %s ---\n' "$sentinel"
            cat "$source_file"
        } >> "$target_file"
        print_success "$target_file 에 추가 완료"
    fi
}

deploy_dotfile() {
    local source="$1"
    local target="$2"
    mkdir -p "$(dirname "$target")"
    if [ -f "$target" ]; then
        print_info "기존 $target 을 $target.bak 으로 백업"
        cp "$target" "$target.bak"
    fi
    cp "$source" "$target"
    print_success "$source -> $target 복사 완료"
}

# ─────────────────────────────────────────────
# 설치 단계
# ─────────────────────────────────────────────

install_apt_packages() {
    print_step "apt 패키지 설치"
    sudo apt-get update -qq

    local packages=(
        git
        curl
        wget
        unzip
        tmux
        tig
        fd-find
        ripgrep
        universal-ctags
        neovim
        python-dev-is-python3
        python3-pip
        python3-dev
    )

    for pkg in "${packages[@]}"; do
        apt_install_if_missing "$pkg"
    done
}

install_fzf() {
    print_step "fzf 설치"
    if [ -d "$HOME/.fzf" ]; then
        print_info "~/.fzf 이미 존재함, 건너뜀"
    else
        git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
        print_success "fzf 클론 완료"
    fi

    print_info "fzf 설치 스크립트 실행 중 (--all --no-update-rc)..."
    "$HOME/.fzf/install" --all --no-update-rc
    print_success "fzf 설치 완료"
}

install_nodejs() {
    print_step "Node.js (LTS) 설치"
    if command_exists node; then
        print_info "node $(node --version) 이미 설치됨, 건너뜀"
        return 0
    fi

    print_info "NodeSource 설정 스크립트 실행 중..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt-get install -y nodejs
    print_success "Node.js $(node --version) 설치 완료"
}

install_yarn() {
    print_step "Yarn 설치"
    if command_exists yarn; then
        print_info "yarn 이미 설치됨, 건너뜀"
        return 0
    fi

    local keyring="/usr/share/keyrings/yarn-archive-keyring.gpg"
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg \
        | sudo gpg --dearmor -o "$keyring"

    echo "deb [signed-by=$keyring] https://dl.yarnpkg.com/debian/ stable main" \
        | sudo tee /etc/apt/sources.list.d/yarn.list > /dev/null

    sudo apt-get update -qq
    sudo apt-get install -y yarn
    print_success "yarn $(yarn --version) 설치 완료"
}

deploy_dotfiles() {
    print_step "dotfile 배포"

    # bashrc: append 방식 (fzf shell integration 포함)
    append_if_absent \
        "$SCRIPT_DIR/bashrc/bashrc" \
        "$HOME/.bashrc" \
        "setup-ubuntu-env: custom bashrc"

    # fzf shell integration (.fzf.bash 소스)
    local fzf_sentinel="setup-ubuntu-env: fzf integration"
    if grep -qF "$fzf_sentinel" "$HOME/.bashrc" 2>/dev/null; then
        print_info "fzf integration 이미 ~/.bashrc 에 포함됨, 건너뜀"
    else
        {
            printf '\n# --- %s ---\n' "$fzf_sentinel"
            printf '[ -f ~/.fzf.bash ] && source ~/.fzf.bash\n'
        } >> "$HOME/.bashrc"
        print_success "fzf integration ~/.bashrc 에 추가 완료"
    fi

    # gitconfig 복사 후 user 정보 적용
    deploy_dotfile "$SCRIPT_DIR/git/gitconfig" "$HOME/.gitconfig"
    git config --global user.name "$GIT_USER_NAME"
    git config --global user.email "$GIT_USER_EMAIL"
    print_success "gitconfig user 정보 설정 완료 ($GIT_USER_NAME <$GIT_USER_EMAIL>)"

    # tigrc
    deploy_dotfile "$SCRIPT_DIR/tig/tigrc" "$HOME/.tigrc"

    # neovim init.vim
    deploy_dotfile "$SCRIPT_DIR/neovim/init.vim" "$HOME/.config/nvim/init.vim"
}

setup_tmux_config() {
    print_step "tmux 설정"
    local tmux_conf="$HOME/.tmux.conf"

    if [ -f "$tmux_conf" ]; then
        print_info "~/.tmux.conf 이미 존재함, 건너뜀"
        return 0
    fi

    cat > "$tmux_conf" << 'EOF'
# 패널 나누기
unbind %
bind h split-window -h

unbind '"'
bind v split-window -v

set -g base-index 1
setw -g pane-base-index 1
EOF
    print_success "~/.tmux.conf 생성 완료"
}

install_vim_plug() {
    print_step "vim-plug 설치"
    local plug_path="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/plug.vim"

    if [ -f "$plug_path" ]; then
        print_info "vim-plug 이미 설치됨, 건너뜀"
        return 0
    fi

    curl -fLo "$plug_path" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    print_success "vim-plug 설치 완료"
}

install_neovim_plugins() {
    print_step "Neovim 플러그인 설치 (PlugInstall)"
    local plugged_dir="$HOME/.config/nvim/plugged"

    if [ -d "$plugged_dir" ] && [ "$(ls -A "$plugged_dir" 2>/dev/null)" ]; then
        print_info "Neovim 플러그인 이미 설치됨, 건너뜀"
        return 0
    fi

    print_info "nvim --headless +PlugInstall 실행 중..."
    nvim --headless +PlugInstall +qa
    print_success "Neovim 플러그인 설치 완료"
}

setup_coc_nvim() {
    print_step "coc.nvim 설정"
    local coc_dir="$HOME/.config/nvim/plugged/coc.nvim"

    if [ ! -d "$coc_dir" ]; then
        print_error "coc.nvim 디렉토리가 없습니다. PlugInstall이 성공했는지 확인하세요."
        return 1
    fi

    if [ -d "$coc_dir/node_modules" ]; then
        print_info "coc.nvim node_modules 이미 존재함, 건너뜀"
        return 0
    fi

    print_info "coc.nvim 에서 yarn install 실행 중..."
    (cd "$coc_dir" && yarn install)
    print_success "coc.nvim 설정 완료"
}

install_jetbrains_font() {
    print_step "JetBrainsMono Nerd Font 설치"
    local font_dir="$HOME/.local/share/fonts"
    local font_check="$font_dir/JetBrainsMonoNerdFont-Regular.ttf"

    if [ -f "$font_check" ]; then
        print_info "JetBrainsMono Nerd Font 이미 설치됨, 건너뜀"
        return 0
    fi

    local tmp_zip
    tmp_zip="$(mktemp /tmp/JetBrainsMono.XXXXXX.zip)"

    print_info "JetBrainsMono.zip 다운로드 중..."
    wget -q -O "$tmp_zip" \
        https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip

    mkdir -p "$font_dir"
    unzip -o "$tmp_zip" -d "$font_dir" '*.ttf' > /dev/null
    rm -f "$tmp_zip"

    fc-cache -fv > /dev/null
    print_success "JetBrainsMono Nerd Font 설치 완료"
}

# ─────────────────────────────────────────────
# main
# ─────────────────────────────────────────────

main() {
    print_step "Ubuntu 개발 환경 설정 시작"
    print_info "스크립트 위치: $SCRIPT_DIR"

    # sudo 권한 확인
    if ! sudo -v 2>/dev/null; then
        print_error "이 스크립트는 sudo 권한이 필요합니다."
        exit 1
    fi

    # Ubuntu 버전 출력
    print_info "Ubuntu 버전: $(lsb_release -rs 2>/dev/null || echo 'unknown')"

    # git user 정보 입력
    print_step "Git 사용자 정보 입력"
    read -rp "  Git 사용자 이름: " GIT_USER_NAME
    read -rp "  Git 이메일: " GIT_USER_EMAIL

    if [ -z "$GIT_USER_NAME" ] || [ -z "$GIT_USER_EMAIL" ]; then
        print_error "이름과 이메일을 모두 입력해야 합니다."
        exit 1
    fi

    install_apt_packages
    install_fzf
    install_nodejs
    install_yarn
    deploy_dotfiles
    setup_tmux_config
    install_vim_plug
    install_neovim_plugins
    setup_coc_nvim
    install_jetbrains_font

    printf "\n${GREEN}=====================================${RESET}\n"
    printf "${GREEN}  설치 완료!${RESET}\n"
    printf "${GREEN}=====================================${RESET}\n"
    printf "\n적용하려면:\n"
    printf "  ${CYAN}source ~/.bashrc${RESET}\n"
    printf "\n폰트 변경은 터미널을 재시작해야 적용됩니다.\n\n"
}

main "$@"
