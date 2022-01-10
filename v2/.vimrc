runtime! archlinux.vim


set autoindent " New lines inherit the indentation of previous lines.
set expandtab " Convert tabs to spaces.
set shiftround " When shifting lines, round the indentation to the nearest multiple of “shiftwidth.”
set shiftwidth=4 " When shifting, indent using four spaces.
set smarttab " Insert “tabstop” number of spaces when the “tab” key is pressed.
set tabstop=4 " Indent using four spaces.
set softtabstop=4
set textwidth=140
set hlsearch " Enable search highlighting.
set ignorecase " Ignore case when searching.
set incsearch " Incremental search that shows partial matches.
set smartcase " Automatically switch search to case-sensitive when search query contains an uppercase letter.
set display+=lastline " Always try to show a paragraph’s last line.
set fileencodings=utf-8,gb18030,gbk "correctly open windows file which encoded with gbk
set encoding=utf-8 " Use an encoding that supports unicode.
set linebreak " Avoid wrapping a line in the middle of a word.
set sidescrolloff=5 " The number of screen columns to keep to the left and right of the cursor.
set wrap " Enable line wrapping.
set laststatus=2 " Always display the status bar.
set wildmenu " Display command line’s tab complete options as a menu.
set tabpagemax=10 " Maximum number of tab pages that can be opened from the command line.
set cursorline " Highlight the line currently under cursor.
set number " Show line numbers on the sidebar.
set relativenumber " Show line number on the current line and relative numbers on all other lines.
set errorbells " enable beep on errors.
set mouse=a " Enable mouse for scrolling and resizing.
set title " Set the window’s title, reflecting the file currently being edited.
set autoread " Automatically re-read files if unmodified inside Vim.
set backspace=indent,eol,start " Allow backspacing over indention, line breaks and insertion start.
set confirm " Display a confirmation dialog when closing an unsaved file.
set formatoptions+=j " Delete comment characters when joining lines.
set nomodeline " Ignore file’s mode lines; use vimrc configurations instead.
set nrformats-=octal " Interpret octal as decimal when incrementing numbers.
set wildignore+=.pyc,.swp " Ignore files matching these patterns when opening files based on a glob pattern.
set linespace=12
"set spell " Enable spellchecking.
set termguicolors "display color"
filetype plugin indent on " Enable indentation rules that are file-type specific.
syntax enable " Enable syntax highlighting.
set scrolloff=1 " The number of screen lines to keep above and below the cursor.                                        
set cmdheight=4 "set bottom cmd window height with four lines"
"fold
set foldmethod=indent " Fold based on indention levels.
set foldnestmax=3 " Only fold up to three nested levels.
set nofoldenable " Disable folding by default.

"set showtabline=2 "always show table"


"key map 
"<CR>:return <C-CR>:ctrl+enter
"\r -> save and run shell script
noremap \r :w<Return>:!./%<CR>
"\# -> comment \3 -> uncomment
noremap <C-/> :'<,'>norm I# <ESC>
noremap <C-/> I# <ESC>
noremap \3 :'<,'>norm x#<Return>
"/+enter -> close search result
noremap /<CR> :nohlsearch<CR>
"Y -> "+y copy clipboard
noremap Y "+y
"ctrl+n -> open/close left file manager pannel
noremap <C-n> :NERDTreeToggle<CR>
"visual_choose+> -> increase indent(TAB)
vnoremap > >gv
"visual_choose+< -> decrease indent(TAB)
vnoremap < <gv
"ctrl+enter+esc -> save and run python
inoremap <C-CR> <ESC>:w<CR>,r   

"auto command
"saving .vimrc leads to resource it
autocmd! bufwritepost .vimrc source %



"use vim-plug to manage plugin
call plug#begin('~/.vim/plugged')
        Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' } "file tree
        Plug 'rrethy/vim-hexokinase', { 'do': 'make hexokinase' }
        Plug 'kien/rainbow_parentheses.vim' "colorlize parent
        Plug 'Yggdroot/indentLine' "python indent line
        "Plug 'Valloric/YouCompleteMe', { 'do': './install.py --clang-completer --system-libclang' } "auto complete
        Plug 'mattn/emmet-vim' "html format
        Plug 'jiangmiao/auto-pairs'
        Plug 'itchyny/lightline.vim' "status bar
        Plug 'joshdick/onedark.vim' "onedark scheme"
        Plug 'arcticicestudio/nord-vim' "color scheme"
        Plug 'ackyshake/VimCompletesMe' "tab to complete file path"
        Plug 'danilamihailov/beacon.nvim' "smooth cursor"
        Plug 'karb94/neoscroll.nvim' "neovim smooth scroll"
        "Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
call plug#end()

"hexokinase display colour in file: backgroundfull/sign_column
let g:Hexokinase_highlighters = [ 'backgroundfull' ]

"neovim smooth cursor setting
let g:beacon_enable = 1
let g:beacon_minimal_jump = 1
let g:beacon_size = 100
nmap n n:Beacon<cr>
nmap N N:Beacon<cr>
nmap * *:Beacon<cr>
nmap # #:Beacon<cr>

"optional setting for scheme
let g:onedark_hide_endofbuffer = 1
let g:onedark_termcolors = 256
let g:onedark_terminal_italics = 1
"color theme
colorscheme onedark
"colorscheme nord

"status bar
"lightline theme liked: molokai material jellybeans darcula ayu_dark
let g:lightline = {
    \ 'colorscheme': 'ayu_dark',
    \ 'component': {
    \   'readonly': '%{&readonly?"":""}',
    \ },
    "\ 'separator': { 'left': '', 'right': '' },
    "\ 'subseparator': { 'left': '', 'right': '' }
    \ }
let g:lightline.tabline = {
    \ 'left': [ [ 'readonly' ], [ 'tabs', 'percent', 'fileencoding' ] ],
    \ 'right': [ [ 'close' ] ] }

"custome theme numbeer
highlight clear LineNr
highlight clear SignColumn
highlight SpellBad ctermbg=red ctermfg=white
highlight Comment cterm=italic
highlight LineNr term=underline ctermfg=gray ctermbg=234
highlight SignColumn term=underline ctermfg=gray ctermbg=232
highlight CursorLineNr term=underline ctermbg=26 ctermfg=gray
highlight CursorLine cterm=NONE ctermbg=234 ctermfg=NONE guibg=NONE guifg=NONE




"style for indent line
"let g:indentLine_char_list = ['|', '¦', '┆', '┊']
let g:indentLine_char_list = ['|', '┆', '┊']

"color for auto-pairs 
let g:rbpt_colorpairs = [
\ ['brown',       'RoyalBlue3'],
\ ['Darkblue',    'SeaGreen3'],
\ ['darkgray',    'DarkOrchid3'],
\ ['darkgreen',   'firebrick3'],
\ ['darkcyan',    'RoyalBlue3'],
\ ['darkred',     'SeaGreen3'],
\ ['darkmagenta', 'DarkOrchid3'],
\ ['brown',       'firebrick3'],
\ ['gray',        'RoyalBlue3'],
\ ['darkmagenta', 'DarkOrchid3'],
\ ['Darkblue',    'firebrick3'],
\ ['darkgreen',   'RoyalBlue3'],
\ ['darkcyan',    'SeaGreen3'],
\ ['darkred',     'DarkOrchid3'],
\ ['red',         'firebrick3'],
\ ]
let g:rbpt_max = 16
let g:rbpt_loadcmd_toggle = 0
au VimEnter * RainbowParenthesesToggle
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadSquare
au Syntax * RainbowParenthesesLoadBraces

