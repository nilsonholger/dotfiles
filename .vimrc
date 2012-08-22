" .vimrc

"
" PATHOGEN
"
call pathogen#runtime_append_all_bundles()
call pathogen#helptags()

"
" SETTINGS
"
" basic
colorscheme desert								" so our eyes won't hurt
syntax on										" psychedelic rainbow
set background=dark								" so our eyes won't explode
set backspace=indent,eol,start					" allow backspacing over #args
set completeopt=menuone,menu,longest			" completion menu settings
set hidden										" if (hidden) do not unload abandoned buffer
set laststatus=2								" always display status line
set modeline									" allow vim modelines
set modelines=1									" process #lines of modeline commands
set scrolloff=3									" always display #lines context
set showcmd										" display partial commands
set whichwrap=<,>,[,],h,l						" can move to next/previous line

" display
set fileformats+=mac	" cause we workin' on the fruity stuff
set foldmethod=syntax	" yes, we like folds, especially intelligent ones
set linebreak			" wrap looooooong lines
set list				" show listchars (see below)
set listchars=tab:\.\ ,trail:_,extends:>,precedes:<
set showbreak=_			" if (linebreaks) prepend to wrapped line
set splitbelow			" do it latin style
set splitright			" even more latin style

" format
set autoindent		" indent current line -> indent new line
set encoding=utf-8	" character encoding
set shiftwidth=4	" # of (auto)indent spaces
set smartindent		" smarter than cindent
set smarttab		" use shiftwidth for ^line tabs
set softtabstop=4	" while (editing) tab = width of # spaces
set tabstop=4		" tab = width of # spaces

" search/substitute
set gdefault	" default to global substitution
set hlsearch	" if (previous search pattern) highlight all matches
set ignorecase	" if (captain obvious is here) ignore comment
set incsearch	" while (typing search pattern) jump to first match
set magic		" magic chars in search pattern
set smartcase	" if (pattern has upper case char) ignore ignorecase

" statusline
set statusline=%<%f\ %h%m%r%w									" file [help][modify][readonly][preview]
set statusline+=\ 												" space
set statusline+=%{fugitive#statusline()}						" git status from fugitive
set statusline+=%=(%{&ft},%{strlen(&fenc)?&fenc:&enc},%{&ff})	" (filetype,encoding,fileformat)
set statusline+=\ 												" space
set statusline+=%-14.(%L,%l-%c%V%)\ %P							" numberOfLines,line-column-virtualColumn ruler

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

"
" AUTOCOMMAND
"
if has("autocmd")
	filetype plugin indent on
	au BufNew * set foldlevel=20
	au BufNewFile,BufRead,BufEnter *.c,*.cc,*.cpp,*.c++,*.h,*.hh,*.hpp set omnifunc=ClangComplete
	au BufReadPost fugitive://* set bufhidden=delete
	au BufWinEnter *.* silent loadview
	au BufWinLeave *.* mkview
	au BufWritePost $MYVIMRC source $MYVIMRC
	au CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif
	au VimEnter * silent if filereadable("Session.vim") | source Session.vim | endif
	au VimResized * exe "normal! \<c-w>="

	"augroup ft_c
	"	au!
	"	au FileType c setlocal foldmethod=syntax
	"augroup END
endif

"
" MAPS
"
" general
nnoremap <leader><space> :noh<CR>
nnoremap <leader>ev <C-w><C-v><C-l>:e $MYVIMRC<CR>
nnoremap <leader>l :set list!<CR>
nnoremap <leader>n :set number!<CR>
nnoremap <leader>s :set spell!<CR>
inoremap <leader>v  <C-O>:set paste<CR><C-r>*<C-O>:set nopaste<CR>
nnoremap <leader>v <C-w>v
nnoremap <leader>W :%s/\s\+$//<CR>:let @/=''<CR>
inoremap jj <ESC>
nnoremap / /\v
vnoremap / /\v
nnoremap <silent> <leader>/ :execute 'vimgrep /'.@/.'/g %'<CR>:copen<CR>
nnoremap <Space> za
vnoremap <Space> za
nnoremap zO zCzO
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

" quickfix
map <silent> <leader>qq :QFix<CR>
map <silent> <leader>qn :cnext<CR>
map <silent> <leader>qp :cprev<CR>

" make
map <silent> <leader>ma :call Make("all")<CR>
map <silent> <leader>mc :call Make("clean")<CR>
map <silent> <leader>mm :call Make(" ")<CR>
map <silent> <leader>mr :call Make("run")<CR>
map <silent> <leader>mt :call Make("todo")<CR>
map <silent> <leader>mv :call Make("VERBOSE=1")<CR>

" fugitive
map <leader>gc :Gcommit<CR>
map <leader>gd :Gdiff<CR>
map <leader>ge :Gedit HEAD<CR>
map <leader>gl :Glog<CR>
map <leader>gr :Gread<CR>
map <leader>gs :Gstatus<CR>
map <leader>gw :Gwrite<CR>

"
" PLUGINS
"
" clang_complete
let g:clang_complete_auto = 0
let g:clang_complete_copen = 0
let g:clang_user_options = '-std=c++11 -stdlib=libc++ -I/home/dkoester/include/c++/v1'

" supertab
let g:SuperTabDefaultCompletionType = "context"

"
" FUNCTIONS
"
" toggle quickfix window
command! -bang -nargs=? QFix call QFixToggle(<bang>0)
function! QFixToggle(forced)
	if exists("g:qfix_win") && a:forced == 0
		cclose
		unlet g:qfix_win
	else
		botright copen 10
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
