" TODO:
"   * ctags
"   * Tab shortcuts

set nocompatible    " Enter the current millenium
filetype plugin on  " Enable filetype plugins
filetype indent on  " Enable indentation settings by filetype
set autoread        " Re-read files automatically when they've been modified outside of Vim
set encoding=utf8   " Set UTF8 as the standard encoding

" Colours
syntax enable  " Enable syntax highlighting

" Netrw
let g:netrw_banner = 0        " Disable directory banner
let g:netrw_liststyle = 3     " Use tree view style by default
let g:netrw_browse_split = 4  " Open files in previous window
let g:netrw_winsize = 20      " Width of 25% of screen
let g:netrw_altv = 1          " Vertical split puts window and cursor on the right instead of the left
let g:netrw_list_hide = netrw_gitignore#Hide()  " Hide files matched by .gitignore

" Finding files
set path+=**  " Search into subfolders, and allow tab completion
set wildmenu  " Display all matching files when tab completing

" Searching files
set ignorecase  " Ignore case when searching
set smartcase   " Be case-sensitive if the search string contains an uppercase character
set hlsearch    " Highlight search results
set incsearch   " Immediately jump to search results as you type

" Shortcuts
let mapleader = ","     " Define comma key as map leader (<leader>), to use in new shortcuts so as
let g:mapleader = ","   " not to conflict with existing Vim keybindings
nmap <leader>w :w!<cr>  " Define leader shortcut for quick saving

" UI
set number      " Show line numbers
set so=5        " Always keep this many lines between the cursor and the screen edge
set ruler       " Always show the current position
set lazyredraw  " Don't redraw while executing macros, to improve performance
set showmatch   " Show matching brackets when the cursor is over them
set mat=2       " Blink for this many tenths of a second when matching brackets
set visualbell  " Set a visual bell for errors instead of a beep

" Text, tab and indents
set expandtab          " Use spaces instead of tabs
set smarttab           " Intelligently interpret spaces as tabs, e.g. when backspacing
set shiftwidth=4       " Set the width in spaces of an automatic indentation level
set tabstop=4          " Set the width of actual tab characters
set softtabstop=4      " The number of spaces that a tab character counts as
set wrap               " Wrap lines
set autoindent         " Enable autoindenting
set smartindent        "
set list               " Display tabs visually
set listchars=tab:·\   "

" Navigation
map j gj          " Make j and k navigate across wrapped lines
map k gk          "
map <C-j> <C-W>j  " Quicker shortcuts for moving between windows
map <C-k> <C-W>k  "
map <C-h> <C-W>h  "
map <C-l> <C-W>l  "
