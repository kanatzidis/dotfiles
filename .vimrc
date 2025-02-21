" Vimrc - VIM startup file
" This is a collection of useful settings, commands etc compiled by Joshua Gross.

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" General
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Sets how many lines of history VIM has to remember
set history=300

" Enable filetype plugin
filetype plugin on
filetype indent on

" Set to auto read when a file is changed from the outside
set autoread

" Fast saving
" nmap <leader>w :w!<cr>

" Always use undofiles.
set undofile
set undodir=~/.undofiles

" When vimrc is edited, reload it.
" I don't think this works.
" autocmd! BufWritePost .vimrc source ~/.vimrc

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" User Interface
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

set so=7 " Set 7 lines to the curors - when moving vertical..
"set wildmenu "Turn on WiLd menu
set ruler "Always show current position
set cmdheight=2 "The commandbar height

syntax enable " Enable syntax highlighting
set re=0
set number " Display line numbers
set nowrap " turn off text wrapping

" Set backspace config
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

" Searching
set incsearch " Incremental searching - shows results WHILE you are typing a search word
set ignorecase smartcase " Make searching case-insensitive by default
set ignorecase "Ignore case when searching
set hlsearch "Highlight search things. To clear highlighting, do :noh
set incsearch "Make search act like search in modern browsers
set magic "Set magic on, for regular expressions (HOW does this work?)
set showmatch "Show matching bracets when text indicator is over them
set mat=2 "How many tenths of a second to blink

" No sound on errors
set noerrorbells
set novisualbell
set t_vb=

" ----- Mac-Vim: copy/paste to/from system clipboard -----
"map *y !pbcopy<CR>u 
"map *p r !pbpaste<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Files and backups
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Turn backup off, since most stuff is in SVN, git anyway...
set nobackup
set nowb
set noswapfile

" ----- Indenting/Tabs -----
" Set tab width
set tabstop=2
" Number of spaces used for auto-indenting. IMPORTANT: should be the
" same as your tabstop or else auto-indenting will be funky!
set expandtab
set shiftwidth=2
" Enable smart indenting
set smartindent si
" Smarter autoindent when pasting blocks of code
nnoremap <F5> :set invpaste paste?<Enter>
imap <F5> <C-O><F5>
set pastetoggle=<F5>
" Correct indentation after opening a phpdoc/javadoc block and automatic * on every line
set formatoptions=qroct
" Spelling
nnoremap <F6> :setlocal spell spelllang=en_us<Enter>
nnoremap <F7> :setlocal spell spelllang=<Enter>

" Fix code listings pasted from Word
noremap <F8> :%s/[‘’]/'/g<Enter>:%s/[“”]/"/g<Enter>:%s/^\s*[0-9]*//g<Enter>

" ----- Useful keyboard shortcut time-savers -----
" Real nice: makes backspace erase over everything
" If you press delete at the beginning of a line, it brings that line
" to the end of the previous line (as you would come to expect using
" modern GUI editors)
set backspace=2

" Easier escape key
ino jj <esc>

" Run tests
function! RunTests()
    let filetype = &filetype
    if filetype ==# "rust"
        let function_name = FindRustTestFunctionName()
        if function_name != ""
            let command = "cargo test " . function_name . " -- --nocapture"
        else
            let command = "cargo test -- --nocapture"
        endif
    else
        let command = ""
    endif

    if command != ""
        execute "!" . command
    endif
endfunction

function! FindRustTestFunctionName()
    let lnum = line('.')  " Start at the cursor position
    let function_name = ""

    " Step 1: Find the nearest function declaration first
    while lnum > 0
        let line_text = getline(lnum)

        " Match Rust function declaration
        if match(line_text, '^\s*fn\s\+\(\k\+\)') >= 0
            let function_name = matchstr(line_text, '^\s*fn\s\+\zs\k\+')
            break
        endif

        let lnum -= 1  " Move to the previous line
    endwhile

    " If no function was found, return empty
    if function_name == ""
        return ""
    endif

    " Step 2: Continue searching upwards for 'mod tests {'
    while lnum > 0
        let line_text = getline(lnum)

        " If we find 'mod tests {', return the function name
        if match(line_text, '^\s*mod tests\s*{') >= 0
            return function_name
        endif

        let lnum -= 1  " Move to the previous line
    endwhile

    " If we didn't find 'mod tests {', return empty
    return ""
endfunction

nnoremap <C-k> :call RunTests()<CR>

"color peachpuff

" Buffer explorer
" README note: This maps TAB to shift one buffer left; SEMICOLON to shift right.
" Try opening 5 or 6 files and then use tab/semicolon to navigate.
noremap ; :next <Enter>
noremap <tab> :prev <Enter>

" Projectify
"source ~/project.vim 

" Custom highlighting
so ~/.vim/plugin/highlights.vim
Highlight 4 TODO
hi Comment guifg=#EEEEEE ctermfg=White
augroup comment_textwidth
    autocmd!
    autocmd TextChanged,TextChangedI * :call AdjustTextWidth()
augroup END

function! AdjustTextWidth()
    let syn_element = synIDattr(synID(line("."), col(".") - 1, 1), "name")
    let &textwidth = syn_element =~? 'comment' ? 72 : 79
    echo "tw = " . &textwidth
endfunction

" Super fancy status line
" http://www.linux.com/archive/feature/120126
:set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [ASCII=\%03.3b]\ [HEX=\%02.2B]\ [POS=%04l,%04v][%p%%]\ [LINES=%L] 

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Env: Assembly
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Assembly code: highlight lines over 80 columns
autocmd FileType asm au BufWinEnter * let w:m1=matchadd('Search', '\%<81v.\%>77v', -1)
autocmd FileType asm au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>80v.\+', -1)

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Env: Objective-C
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
au BufNewFile,BufRead *.m,*.h set ft=objc

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Env: LaTeX/HTML
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
autocmd FileType tex,html,txt au BufWinEnter * set wrap
autocmd FileType tex,html,txt nmap <silent> j gj
autocmd FileType tex,html,txt nmap <silent> k gk
autocmd FileType tex,html,txt vmap <silent> j gj
autocmd FileType tex,html,txt vmap <silent> k gk

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Display 80 character threshold
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"command Threshold let &colorcolumn=join(range(81,999),",") | highlight ColorColumn ctermbg=124 guibg=LightRed
"command Nothreshold let &colorcolumn=0

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Set soft line navigation
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"command Softnav nmap <silent> j gj| nmap <silent> k gk| vmap <silent> j gj| vmap <silent> k gk

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Instantiate Pathogen
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
execute pathogen#infect()
