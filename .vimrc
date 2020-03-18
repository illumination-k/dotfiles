" encoding
set encoding=utf-8

" display
set number
set cursorline

"" status bar
set laststatus=2
set showmode
set ruler
set ruler

" tab
set expandtab
set autoindent
set tabstop=4
set smartindent
set shiftwidth=4

" search
set hlsearch
set ignorecase
set incsearch
set smartcase

" utils
set showmatch
set virtualedit=onemore
set backspace=indent,eol,start

" complemnt
set wildmenu

" set syntax
let OSTYPE = system('uname')
if OSTYPE == "Darwin\n" 
    :set term=xterm-256color 
    :syntax on
elseif OSTYPE == "Linux\n"
    :syntax on
endif 
