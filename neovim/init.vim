call plug#begin('~/.config/nvim/plugged')
" Fzf
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Use release branch
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" Or latest tag
Plug 'neoclide/coc.nvim', {'tag': '*', 'branch': 'release'}
" Or build from source code by use yarn: [https://yarnpkg.com](https://yarnpkg.com/)
Plug 'neoclide/coc.nvim', {'do': 'yarn install --frozen-lockfile'}
"NerdTree
Plug 'scrooloose/nerdtree'
"tagbar
Plug 'majutsushi/tagbar'
"any-jump
Plug 'pechorin/any-jump.vim'

"Colors
Plug 'morhetz/gruvbox'
Plug 'terroo/terroo-colors'
Plug 'tomasr/molokai'
Plug 'joshdick/onedark.vim'
Plug 'jacoborus/tender'
Plug 'nanotech/jellybeans.vim'
Plug 'rakr/vim-one'
Plug 'altercation/vim-colors-solarized'

"Statusline/Tabline
"Plug 'itchyny/lightline.vim'

"Airline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

"git plugin
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'

"multiline edit
Plug 'terryma/vim-multiple-cursors'

"file manager
Plug 'francoiscabrol/ranger.vim'
Plug 'rbgrouleff/bclose.vim'

"line guide
Plug 'yggdroot/indentline'

"all trailing whitespace characters to be highlighted
Plug 'ntpeters/vim-better-whitespace'

"Comment functions
Plug 'scrooloose/nerdcommenter'

"hybrid number toggle
Plug 'jeffkreeftmeijer/vim-numbertoggle'

"highlighted plugin
Plug 't9md/vim-quickhl'

"bookmarks
Plug 'kshenoy/vim-signature'

"window resize
Plug 'simeji/winresizer'

"kotlin
Plug 'udalov/kotlin-vim'
call plug#end()

"common settings
set nocp
set hi=1000
set bs=indent,eol,start
set ru
set ts=4
set sts=4
set sw=4
set cindent
set ls=2
set si
set ai
"set hls
set number
set ignorecase
set fileencoding=utf-8
set tabstop=4 shiftwidth=4 expandtab

set hidden
set autoread

set colorcolumn=100

"set mouse=a

"Color
"set t_Co=256
colorscheme gruvbox

"key mapping
map <F2> <c-w><c-w>
map <F3> :NERDTreeToggle<CR>
map <F4> :TagbarToggle<cr>
map <F5> :bprevious<CR>
map <F6> :bnext<CR>
imap <F5> <ESC>:bprevious!<CR>
imap <F6> <ESC>:bnext!<CR>

nnoremap <C-t> :Files<Cr>
nmap <Leader>bb :Buffers<CR>
nmap <Leader>ll :Lines<CR>

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <Leader>f  <Plug>(coc-format-selected)

" NerdTree show hidden
let NERDTreeShowHidden=1

" AnyJump navigation
nmap <silent> aj :AnyJump<CR>
nmap <silent> ajb :AnyJumpBack<CR>

"gitGuttter
nmap <Leader>ge :GitGutterEnable<CR>
nmap <Leader>gt :GitGutterToggle<CR>
nmap <Leader>gl :GitGutterLineNrHighlightsToggle<CR>
nmap ]h <Plug>(GitGutterNextHunk)
nmap [h <Plug>(GitGutterPrevHunk)
nmap ghp <Plug>(GitGutterPreviewHunk)

"vim-quickhl
nmap <Space>h <Plug>(quickhl-manual-this)
xmap <Space>h <Plug>(quickhl-manual-this)
nmap <Space>H <Plug>(quickhl-manual-reset)
xmap <Space>H <Plug>(quickhl-manual-reset)

"mouse set
map <Space>m :KmouseToggle<CR>

" fzf
if has('nvim') || v:version >= 802
let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.8 } }
let g:fzf_preview_window = 'up:60%'
else
let g:fzf_layout = {'down': '60%'}
let g:fzf_preview_window = ''
endif

" Rg
nmap <Leader>rg :Rg <C-R>=expand("<cword>")<CR><CR>

"nmap <C-t> :Find <C-R>=expand("<cword>")<CR><CR>

"gommand!    -bang -nargs=* Find   call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case -- ".shellescape(<q-args>), 1, fzf#vim#with_preview('up:40%'), <bang>0)

"command! -bang -nargs=* Find call fzf#vim#grep('rg --column --line-number --no-heading --fixed-strings --ignore-case --no-ignore --follow --glob "!.git/*" -g "!*.class" -g "!tags" -g "!*.d" -g "!*.d.*" --color "always" '.shellescape(<q-args>).'| tr -d "\017"', 1, fzf#vim#with_preview('up:50%'), <bang>0)

"let g:fzf_colors =
"    \ { 'fg':      ['fg', 'Normal'],
"      \ 'bg':      ['bg', 'Normal'],
"      \ 'hl':      ['fg', 'Comment'],
"      \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
"      \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
"      \ 'hl+':     ['fg', 'Statement'],
"      \ 'info':    ['fg', 'PreProc'],
"      \ 'border':  ['fg', 'Ignore'],
"      \ 'prompt':  ['fg', 'Conditional'],
"      \ 'pointer': ['fg', 'Exception'],
"      \ 'marker':  ['fg', 'Keyword'],
"      \ 'spinner': ['fg', 'Label'],
"      \ 'header':  ['fg', 'Comment'] }

"airline
let g:airline#extensions#tabline#enabled = 1 " turn on buffer list
let g:airline_powerline_fonts = 1
set laststatus=2
let g:airline#extensions#tabline#fnamemod = ':t' " name only in tabline
let g:airline_theme='hybrid'
let g:airline#extensions#whitespace#enabled = 0
let g:airline_section_c = '%t'

"any jump
let g:any_jump_search_prefered_engine = 'ag'
let g:any_jump_window_width_ratio  = 0.9
let g:any_jump_window_height_ratio = 0.8
let g:any_jump_window_top_offset   = 5

"coustom functions
fun NoNumRelative()
:set nonu
:set norelativenumber
:IndentLinesDisable
endfun

fun NumRelative()
:set nu
:set relativenumber
:IndentLinesEnable
endfun

let s:mouseToggle = 0
fun MouseEnableToggle()
if s:mouseToggle
:set mouse=a
let s:mouseToggle = 0
else
:set mouse=""
let s:mouseToggle = 1
endif
endfun

command! Knonum call NoNumRelative()
command! Knum call NumRelative()
command! KmouseToggle call MouseEnableToggle()
