""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" General
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
filetype plugin indent on
set autoread

" persistent undo across sessions
if !isdirectory(expand('~/.undofiles'))
    call mkdir(expand('~/.undofiles'), 'p')
endif
set undofile
set undodir=~/.undofiles

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" User Interface
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set scrolloff=7              " keep 7 lines above/below cursor
set ruler                    " show cursor position
set cmdheight=2              " taller command area to avoid "Press ENTER" prompts

syntax enable
set number
set nowrap

set backspace=eol,start,indent
set whichwrap+=<,>,h,l       " cursor keys wrap across lines

" searching
set incsearch                " show matches while typing
set ignorecase smartcase     " case-insensitive unless uppercase is used
set hlsearch                 " highlight matches (:noh to clear)
set showmatch                " flash matching bracket
set mat=2                    " bracket flash duration (tenths of a second)

" silence
set noerrorbells
set novisualbell
set t_vb=

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Files and backups
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set nobackup
set nowb
if !isdirectory(expand('~/.swapfiles'))
    call mkdir(expand('~/.swapfiles'), 'p')
endif
set directory=~/.swapfiles

" 2-space soft tabs
set tabstop=2
set expandtab
set shiftwidth=2

" paste mode toggle
nnoremap <F5> :set invpaste paste?<Enter>
imap <F5> <C-O><F5>
set pastetoggle=<F5>

set formatoptions=qroct      " auto-format comments (* continuation, etc.)

" F6: toggle spell check
nnoremap <F6> :setlocal spell! spelllang=en_us<Enter>

" F8: fix curly quotes and strip line numbers from pasted text
noremap <F8> :%s/['']/'/g<Enter>:%s/[""]/"/g<Enter>:%s/^\s*[0-9]*//g<Enter>

" jj exits insert mode
ino jj <esc>

let mapleader = " "

" buffer navigation
noremap ; :next<Enter>
noremap <leader><tab> :prev<Enter>

" highlight TODOs
match Todo /TODO/
hi Comment guifg=#EEEEEE ctermfg=White

" auto-adjust textwidth: 72 in comments, 79 in code
augroup comment_textwidth
    autocmd!
    autocmd TextChanged,TextChangedI * :call AdjustTextWidth()
augroup END

function! AdjustTextWidth()
    let syn_element = synIDattr(synID(line("."), col(".") - 1, 1), "name")
    let &textwidth = syn_element =~? 'comment' ? 72 : 79
endfunction

" tab completion in insert mode
inoremap <Tab> <C-N>
inoremap <S-Tab> <C-P>

set colorcolumn=81

" prose filetypes: wrap lines and navigate by visual lines
augroup prose
    autocmd!
    autocmd FileType tex,html,txt setlocal wrap
    autocmd FileType tex,html,txt nmap <buffer> <silent> j gj
    autocmd FileType tex,html,txt nmap <buffer> <silent> k gk
    autocmd FileType tex,html,txt vmap <buffer> <silent> j gj
    autocmd FileType tex,html,txt vmap <buffer> <silent> k gk
augroup END
