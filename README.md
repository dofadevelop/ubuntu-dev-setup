# dotfiles

Ubuntu 개발 환경을 처음부터 빠르게 세팅하기 위한 dotfiles 및 자동 설치 스크립트.

## 빠른 시작

```bash
git clone <repo-url> ~/dotfiles
cd ~/dotfiles
bash install.sh
```

## 설치 항목

### 패키지
| 도구 | 설명 |
|---|---|
| tmux | 터미널 멀티플렉서 |
| tig | TUI Git 브라우저 |
| fd-find | 빠른 파일 탐색 (`fd` alias) |
| fzf | 퍼지 파인더 (Ctrl+R, Ctrl+T) |
| ripgrep | 빠른 텍스트 검색 (`rg`) |
| universal-ctags | 코드 태그 생성 |
| neovim | 텍스트 에디터 |
| Node.js LTS | JavaScript 런타임 |
| yarn | JavaScript 패키지 매니저 |

### Dotfiles
| 파일 | 배포 위치 |
|---|---|
| `bashrc/bashrc` | `~/.bashrc` 에 append |
| `git/gitconfig` | `~/.gitconfig` |
| `tig/tigrc` | `~/.tigrc` |
| `tmux/tmux.conf` | `~/.tmux.conf` |
| `neovim/init.vim` | `~/.config/nvim/init.vim` |

### 기타
- SSH 키 생성 (`~/.ssh/id_ed25519`, ed25519)
- Neovim 플러그인 설치 (vim-plug + PlugInstall)
- JetBrainsMono Nerd Font 설치
- Codex 스킬 배포 (`~/.codex/skills/`)

## 디렉토리 구조

```
dotfiles/
├── install.sh              # 자동 설치 스크립트
├── bashrc/
│   └── bashrc              # git branch 프롬프트, fd/u alias
├── git/
│   └── gitconfig           # fzf 연동 alias (bselect, lg 등)
├── tig/
│   └── tigrc               # tig 설정
├── tmux/
│   └── tmux.conf           # 패널 분할 키 바인딩
├── neovim/
│   └── init.vim            # vim-plug, coc.nvim, NERDTree 등
└── ai-agent/
    └── codex/
        └── git-auto-commit/ # Codex 스킬
```

## config 개별 적용

설정 파일 수정 후 해당 항목만 다시 적용할 수 있습니다.

```bash
bash install.sh apply <config>
```

| config | 설명 |
|---|---|
| `ssh` | SSH 키 생성 (ed25519) |
| `bashrc` | `~/.bashrc` 업데이트 |
| `git` | `~/.gitconfig` 복사 |
| `tig` | `~/.tigrc` 복사 |
| `nvim` | `~/.config/nvim/init.vim` 복사 |
| `tmux` | `~/.tmux.conf` 복사 |
| `codex` | `~/.codex/skills/` 에 스킬 배포 |

```bash
# 예시: neovim 설정 변경 후 바로 적용
bash install.sh apply nvim
```

## Codex 스킬

`ai-agent/codex/` 에 스킬 디렉토리를 추가하면 `install.sh` 실행 시 자동으로 `~/.codex/skills/` 에 배포됩니다.

```
ai-agent/codex/
└── my-skill/
    └── SKILL.md   # 필수
```

```bash
# 스킬만 다시 배포
bash install.sh apply codex
```

## 설치 후

```bash
# 설정 즉시 적용
source ~/.bashrc

# 폰트 적용은 터미널 재시작 필요
# SSH 공개 키는 GitHub에 등록
# https://github.com/settings/ssh/new
```
