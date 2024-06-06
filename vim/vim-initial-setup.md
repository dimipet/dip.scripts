Create needed directory
```
$ mkdir -p ~/.vim/pack/vendor/start
```

Install vim-plug plugin manager
```
$ curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```
Create vim config file and paste initial configuration
```
$ nano ~/.vimrc 
syntax on
set number
call plug#begin()
Plug 'preservim/NERDTree'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
call plug#end()
```
Install plugins
```
$ vim
:PlugInstall
```
Choose a theme from https://github.com/vim-airline/vim-airline/wiki/Screenshots and set it
```
:AirlineTheme <theme>
```
