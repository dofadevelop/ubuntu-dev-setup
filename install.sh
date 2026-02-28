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

install_docker() {
    print_step "Docker Engine 설치 (Ubuntu 24.04 가이드 기반)"

    local conflict_packages=(
        docker.io
        docker-doc
        docker-compose
        docker-compose-v2
        podman-docker
        containerd
        runc
    )

    for pkg in "${conflict_packages[@]}"; do
        if dpkg -s "$pkg" &>/dev/null; then
            print_info "충돌 패키지 제거: $pkg"
            sudo apt-get remove -y "$pkg"
        fi
    done

    sudo apt-get update -qq
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    local arch codename
    arch="$(dpkg --print-architecture)"
    codename="$(. /etc/os-release && echo "$VERSION_CODENAME")"

    echo \
      "deb [arch=$arch signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $codename stable" \
      | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update -qq
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    sudo systemctl enable docker
    sudo systemctl start docker

    if getent group docker >/dev/null; then
        if id -nG "$USER" | grep -qw docker; then
            print_info "사용자 $USER 는 이미 docker 그룹에 포함됨"
        else
            sudo usermod -aG docker "$USER"
            print_info "사용자 $USER 를 docker 그룹에 추가함 (새 로그인 세션부터 적용)"
        fi
    fi

    if sudo docker run --rm hello-world >/dev/null 2>&1; then
        print_success "sudo docker run hello-world 확인 완료"
    else
        print_error "sudo docker run hello-world 실행 실패. Docker 데몬 상태를 확인하세요."
    fi

    if docker compose version >/dev/null 2>&1; then
        print_success "docker compose plugin 확인 완료"
    else
        print_error "docker compose plugin 확인 실패"
    fi
}

prompt_git_info() {
    read -rp "  Git 사용자 이름: " GIT_USER_NAME
    read -rp "  Git 이메일: " GIT_USER_EMAIL

    if [ -z "$GIT_USER_NAME" ] || [ -z "$GIT_USER_EMAIL" ]; then
        print_error "이름과 이메일을 모두 입력해야 합니다."
        exit 1
    fi
}

setup_ssh() {
    print_step "SSH 키 설정"
    local ssh_dir="$HOME/.ssh"
    local key_file="$ssh_dir/id_ed25519"

    mkdir -p "$ssh_dir"
    chmod 700 "$ssh_dir"

    if [ -f "$key_file" ]; then
        print_info "SSH 키 이미 존재함 ($key_file), 건너뜀"
        printf "\n  공개 키 (GitHub 등에 등록):\n"
        cat "$key_file.pub"
        printf "\n"
        return 0
    fi

    local email="${GIT_USER_EMAIL:-}"
    if [ -z "$email" ]; then
        read -rp "  SSH 키 코멘트 (이메일): " email
    fi

    ssh-keygen -t ed25519 -C "$email" -f "$key_file" -N ""
    chmod 600 "$key_file"
    print_success "SSH 키 생성 완료 ($key_file)"

    printf "\n  아래 공개 키를 GitHub에 등록하세요:\n"
    printf "  https://github.com/settings/ssh/new\n\n"
    cat "$key_file.pub"
    printf "\n"
}

apply_bashrc() {
    print_step "bashrc 적용"
    append_if_absent \
        "$SCRIPT_DIR/bashrc/bashrc" \
        "$HOME/.bashrc" \
        "setup-ubuntu-env: custom bashrc"

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
}

apply_git() {
    print_step "gitconfig 적용"
    if [ -z "${GIT_USER_NAME:-}" ] || [ -z "${GIT_USER_EMAIL:-}" ]; then
        prompt_git_info
    fi
    deploy_dotfile "$SCRIPT_DIR/git/gitconfig" "$HOME/.gitconfig"
    git config --global user.name "$GIT_USER_NAME"
    git config --global user.email "$GIT_USER_EMAIL"
    print_success "user 정보 설정 완료 ($GIT_USER_NAME <$GIT_USER_EMAIL>)"
}

apply_tig() {
    print_step "tigrc 적용"
    deploy_dotfile "$SCRIPT_DIR/tig/tigrc" "$HOME/.tigrc"
}

apply_nvim() {
    print_step "neovim init.vim 적용"
    deploy_dotfile "$SCRIPT_DIR/neovim/init.vim" "$HOME/.config/nvim/init.vim"
}

apply_tmux() {
    print_step "tmux 설정 적용"
    deploy_dotfile "$SCRIPT_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"
}

apply_codex_skills() {
    print_step "Codex 스킬 배포"
    local skills_src="$SCRIPT_DIR/ai-agent/codex"
    local skills_dst="$HOME/.codex/skills"

    if [ ! -d "$skills_src" ]; then
        print_info "ai-agent/codex 디렉토리 없음, 건너뜀"
        return 0
    fi

    mkdir -p "$skills_dst"

    local count=0
    for skill_dir in "$skills_src"/*/; do
        [ -d "$skill_dir" ] || continue
        local skill_name
        skill_name="$(basename "$skill_dir")"
        print_info "스킬 복사: $skill_name → $skills_dst/$skill_name"
        rm -rf "$skills_dst/$skill_name"
        cp -r "${skill_dir%/}" "$skills_dst/$skill_name"
        count=$((count + 1))
    done

    if [ "$count" -eq 0 ]; then
        print_info "배포할 스킬 없음"
    else
        print_success "Codex 스킬 $count 개 배포 완료"
    fi
}

deploy_dotfiles() {
    apply_bashrc
    apply_git
    apply_tig
    apply_nvim
}

setup_tmux_config() {
    if [ -f "$HOME/.tmux.conf" ]; then
        print_info "~/.tmux.conf 이미 존재함, 건너뜀"
        return 0
    fi
    apply_tmux
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

cmd_apply() {
    local config="${1:-}"
    case "$config" in
        ssh)    setup_ssh ;;
        bashrc) apply_bashrc ;;
        git)    apply_git ;;
        tig)    apply_tig ;;
        nvim)   apply_nvim ;;
        tmux)   apply_tmux ;;
        codex)  apply_codex_skills ;;
        *)
            print_error "알 수 없는 config: '${config}'"
            printf "\n사용법: %s apply <config>\n" "$(basename "$0")"
            printf "  config 목록:\n"
            printf "    ssh     - SSH 키 생성 (ed25519)\n"
            printf "    bashrc  - ~/.bashrc 에 커스텀 설정 추가\n"
            printf "    git     - ~/.gitconfig 복사\n"
            printf "    tig     - ~/.tigrc 복사\n"
            printf "    nvim    - ~/.config/nvim/init.vim 복사\n"
            printf "    tmux    - ~/.tmux.conf 생성\n"
            printf "    codex   - ~/.codex/skills/ 에 스킬 복사\n"
            exit 1
            ;;
    esac
    printf "\n${GREEN}완료!${RESET}\n"
}

cmd_help() {
    printf "사용법: %s [apply <config>]\n\n" "$(basename "$0")"
    printf "  (인수 없음)       전체 설치 실행\n"
    printf "  apply <config>    특정 config 파일만 적용\n\n"
    printf "config 목록:\n"
    printf "  ssh     - SSH 키 생성 (ed25519)\n"
    printf "  bashrc  - ~/.bashrc 에 커스텀 설정 추가\n"
    printf "  git     - ~/.gitconfig 복사\n"
    printf "  tig     - ~/.tigrc 복사\n"
    printf "  nvim    - ~/.config/nvim/init.vim 복사\n"
    printf "  tmux    - ~/.tmux.conf 생성\n"
    printf "  codex   - ~/.codex/skills/ 에 스킬 복사\n"
}

main() {
    case "${1:-}" in
        apply)
            cmd_apply "${2:-}"
            return
            ;;
        help|--help|-h)
            cmd_help
            return
            ;;
    esac

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
    prompt_git_info

    install_apt_packages
    install_fzf
    install_nodejs
    install_yarn
    install_docker
    setup_ssh
    deploy_dotfiles
    setup_tmux_config
    apply_codex_skills
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
