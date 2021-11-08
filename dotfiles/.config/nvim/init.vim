set nocompatible    " Disable compatibility with old Vim
filetype plugin on  " Enable filetype plugins
filetype indent on  " Enable indentation settings by filetype
set autoread        " Re-read files automatically when they've been modified outside of Vim
set encoding=utf8   " Set UTF8 as the standard encoding

" File management
set nobackup        " Disable file backups

" Colours
syntax enable  " Enable syntax highlighting

" Searching files
set ignorecase  " Ignore case when searching
set smartcase   " Be case-sensitive if the search string contains an uppercase character
set hlsearch    " Highlight search results
set incsearch   " Immediately jump to search results as you type

" UI
set number           " Show line numbers
set so=5             " Always keep this many lines between the cursor and the screen edge
set ruler            " Always show the current position
set lazyredraw       " Don't redraw while executing macros, to improve performance
set showmatch        " Show matching brackets when the cursor is over them
set mat=2            " Blink for this many tenths of a second when matching brackets
set visualbell       " Set a visual bell for errors instead of a beep
set colorcolumn=100  " Visual cue for line width at 100 columns

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
