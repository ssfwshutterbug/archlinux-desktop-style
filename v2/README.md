1. 为什么使用nvim
         对于个人来说，用nvim的唯一原因是有两个插件可以实现页面的平滑滚动

2. nvim的下载
   pacman -S neovim

3. nvim配置的几种方式
   1）可以用lua写自己的配置文件~/.config/nvim/init.lua
   
   2）可以直接复制vim的配置文件：
      cp ~/.vimrc ~/.config/nvim/init.vim
      cp ~/.vim/autoload/ ~/.local/share/nvim/site/autoload/
      
   3) 调用vim的配置文件,这也是我所使用的方式
      touch ~/.config/nvim/init.vim
      
      echo "set runtimepath^=~/.vim runtimepath+=~/.vim/after
      let &packpath = &runtimepath
      source ~/.vimrc
      " > ~/.config/nvim/init.vim
      
4. 个人主题配置
        我的vim原本有一些自定义的颜色，但是使用nvim后这些配置不生效了，可以在nvim的配置文件中添加以下语句让自定义的颜色生效
   set termguicolors
   set cul
   hi CursorLine guibg=#171717 guifg=None
   hi CursorLineNr guibg=#004eb0 guifg=gray
   hi LineNr guibg=#171717 guifg=gray
   hi SignColumn guibg=black guifg=gray
   
5. nvim的插件怎么下载，可以在github上找到喜欢的插件，然后写入到vim的配置文件~/.vimrc中，用vim的插件管理器下载即可，和之前使用vim一样