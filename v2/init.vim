set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

lua require('neoscroll').setup()

set termguicolors
set cul
hi CursorLine guibg=#171717 guifg=None
hi CursorLineNr guibg=#004eb0 guifg=gray
hi LineNr guibg=#171717 guifg=gray
hi SignColumn guibg=black guifg=gray

