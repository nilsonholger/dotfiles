" .vimrc

" pathogen
call pathogen#runtime_append_all_bundles()
call pathogen#helptags()

" basic
colorscheme desert
syntax on
set background=dark
set backspace=eol,start,indent
set hidden
set laststatus=2
set nobackup
set nocompatible
set noerrorbells
set modelines=0
set scrolloff=3
set showcmd
set ruler
set novisualbell
set whichwrap=<,>,[,],h,l

" display
set fileformats+=mac
set foldmethod=syntax
set linebreak
set list
set listchars=tab:\|\ ,trail:_,extends:>,precedes:<
set showbreak=_
set splitbelow
set splitright

" format
set autoindent
set encoding=utf-8
set expandtab
set shiftwidth=4
set smartindent
set smarttab
set softtabstop=4
set tabstop=4

" search/substitute
set gdefault
set hlsearch
set ignorecase
set incsearch
set magic
set showmatch
set smartcase

" statusline
set statusline=%f%h%m%r%w
set statusline+=%{fugitive#statusline()}
set statusline+=%=
set statusline+=(%{&ff},%{strlen(&fenc)?&fenc:&enc},%{&ft})
set statusline+=\ 
set statusline+=%03b\:0x%02B
set statusline+=\ 
set statusline+=%l\/%L:%03c

" wildmenu
set wildmenu
"set wildmode=list:longest
set wildignore+=.hg,.git,.svn                    " Version control
set wildignore+=*.aux,*.out,*.toc                " LaTeX intermediate files
set wildignore+=*.jpg,*.bmp,*.gif,*.png,*.jpeg   " binary images
set wildignore+=*.o,*.obj,*.exe,*.dll,*.manifest " compiled object files
set wildignore+=*.spl                            " compiled spelling word lists
set wildignore+=*.sw?                            " Vim swap files
set wildignore+=*.DS_Store                       " OSX bullshit

" autocommand
if has("autocmd")
    filetype plugin indent on
    au BufNew * set foldlevel=20
    au BufRead *.c set cindent
    au BufRead *.py set nocindent nosmartindent autoindent
    au BufReadPost fugitive://* set bufhidden=delete
    au BufWinEnter *.* silent loadview
    au BufWinLeave *.* mkview
    au BufWritePost .vimrc source $MYVIMRC
    au FocusLost * :wa
    "au VimEnter * silent if filereadable("session.vim") | source session.vim | endif
    au VimResized * exe "normal! \<c-w>="

    augroup ft_c
        au!
        au FileType c setlocal foldmethod=syntax
    augroup END
endif

" maps
"let mapleader = ";"
map <silent> <Leader>p <Plug>ToggleProject
map <silent> <leader>N :NERDTreeToggle<CR>
map <silent> <leader>t :TlistToggle<CR>
map <silent> <leader>q :QFix<CR>
map <silent> <leader>ma :call Make("all")<CR>
map <silent> <leader>mc :call Make("clean")<CR>
map <silent> <leader>mm :call Make(" ")<CR>
map <silent> <leader>mr :call Make("run")<CR>
map <silent> <leader>mt :call Make("todo")<CR>
map <silent> <leader>mv :call Make("VERBOSE=1")<CR>
map <silent> <leader>T :!ctags -R -I --languages=c++ --c++-kinds=+p --fields=+iaS --extra=+q .<CR><CR>
nmap <leader>l :set list!<CR>
nmap <leader>s :set spell!<CR>
imap <leader>v  <C-O>:set paste<CR><C-r>*<C-O>:set nopaste<CR>

map <leader>gc :Gcommit<CR>
map <leader>gd :Gdiff<CR>
map <leader>ge :Gedit HEAD<CR>
map <leader>gl :Glog<CR>
map <leader>gr :Gread<CR>
map <leader>gs :Gstatus<CR>
map <leader>gw :Gwrite<CR>

nnoremap <leader><space> :noh<CR>
nnoremap <leader>n :set number!<CR>
nnoremap <leader>ev <C-w><C-v><C-l>:e $MYVIMRC<CR>
nnoremap <leader>W :%s/\s\+$//<CR>:let @/=''<CR>
inoremap jj <ESC>
nnoremap / /\v
vnoremap / /\v
nnoremap <silent> <leader>/ :execute 'vimgrep /'.@/.'/g %'<CR>:copen<CR>
nnoremap <Space> za
vnoremap <Space> za
nnoremap zO zCzO
noremap <leader>v <C-w>v
vnoremap < <gv
vnoremap > >gv

" arrow keys
nnoremap <up> <nop>
nnoremap <down> <nop>
nnoremap <left> <nop>
nnoremap <right> <nop>
inoremap <up> <nop>
inoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>
nnoremap j gj
nnoremap k gk

" windows
noremap <C-h>  <C-w>h
noremap <C-j>  <C-w>j
noremap <C-k>  <C-w>k
noremap <C-l>  <C-w>l

" automatically open and close the popup menu / preview window
au CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif
set completeopt=menuone,menu,longest,preview

" ctags
let Tlist_Ctags_Cmd="ctags"
let Tlist_Close_On_Select=1
let Tlist_Use_Right_Window=1

" toggle quickfix window
command! -bang -nargs=? QFix call QFixToggle(<bang>0)
function! QFixToggle(forced)
    if exists("g:qfix_win") && a:forced == 0
        cclose
        unlet g:qfix_win
    else
        copen 15
      let g:qfix_win = bufnr("$")
    endif
endfunction

" make
function! Make(target)
    if filereadable('Makefile')
        let &makeprg="make " . a:target
    elseif filereadable('build/Makefile')
        let &makeprg="(cd build && make " . a:target . ")"
    elseif filereadable('SConstruct')
        set makeprg=scons
    elseif expand('%:e') == 'csd'
        set makeprg=csound\ %
    elseif expand('%:e') == 'orc' || expand('%:e') == 'sco'
        set makeprg=csound\ '%:r.'orc\ '%:r.'sco
    endif
    :silent w
    :silent make
    :redraw!
    :cc!
endfunction
