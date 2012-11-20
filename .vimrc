" .vimrc
"
" VUNDLE
"
set nocompatible
filetype off
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" manage self
Bundle 'gmarik/vundle'

" bundles
Bundle 'bufexplorer.zip'
Bundle 'Rip-Rip/clang_complete'
Bundle 'gnupg'
Bundle 'ervandew/supertab'
Bundle 'tpope/vim-fugitive'

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
"set scrolloff=3									" always display #lines context
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

" various
let g:changelog_username = "NilsonHolger <nilsonholger@hyve.org>"

"
" AUTOCOMMAND
"
if has("autocmd")
	filetype plugin indent on
	au BufNew * set foldlevel=20
	au BufNewFile,BufRead,BufEnter *.c,*.cc,*.cpp,*.c++,*.h,*.hh,*.hpp set omnifunc=ClangComplete
	au BufReadPost fugitive://* set bufhidden=delete
	au BufReadPost * silent! normal g;zz
	au! BufWritePost $MYVIMRC source $MYVIMRC
	au CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif
	au VimEnter * silent if filereadable("Session.vim") | source Session.vim | endif
	au VimLeave * silent if filereadable("Session.vim") | mksession!  Session.vim | endif
	au VimResized * exe "normal! \<c-w>="
endif

"
" MAPS
"
" general
nnoremap <leader><space> :noh<CR>
nnoremap <leader>c :<c-u>call ToggleComment('false')<cr>
vnoremap <leader>c :<c-u>call ToggleComment('true')<cr>
nnoremap <leader>C :call ToggleColorColumn()<cr>
nnoremap <leader>ev <C-w><C-v><C-l>:e $MYVIMRC<CR>
nnoremap <leader>h :call SwitchHS()<cr>
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
map <silent> <leader>at :call Ack("TODO")<CR>
map <silent> <leader>aa :call Ack("ask")<CR>
map <silent> <leader>mv :call Make("VERBOSE=1")<CR>

" fugitive
map <leader>gc :Gcommit<CR>
map <leader>gd :Gdiff<CR>
map <leader>ge :Gedit HEAD<CR>
map <leader>gl :Glog<CR>
map <leader>gr :Gread<CR>
map <leader>gs :Gstatus<CR>
map <leader>gw :Gwrite<CR>

" bvsd-fifo control
map <leader>ui :execute "! echo r > build/bin/bvsd-fifo"<cr><cr>
map <leader>uu :execute "! echo s > build/bin/bvsd-fifo"<cr><cr>
map <leader>ud :execute "! echo p > build/bin/bvsd-fifo"<cr><cr>
map <leader>ue :execute "! echo q > build/bin/bvsd-fifo"<cr><cr>
map <leader>uh :execute "! echo hs " . expand('%:t:r') . " > build/bin/bvsd-fifo"<cr><cr>

"
" COLOR
"
hi Pmenu		ctermbg=black		ctermfg=brown	cterm=none
hi PmenuSel		ctermbg=red			ctermfg=black	cterm=none
hi PmenuSbar	ctermbg=darkgrey					cterm=none
hi PmenuThumb	ctermbg=yellow						cterm=none

"
" PLUGINS
"
" clang_complete
let g:clang_complete_auto = 0
let g:clang_complete_copen = 0
let g:clang_user_options = '-std=c++11 -stdlib=libc++ -I/home/dkoester/local/include/c++/v1'
if has("python")
	"let g:clang_library_path = '/home/dkoester/local/lib'
	"let g:clang_use_library = 1
endif

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
	:silent make!
	:redraw!
	:redir => l:message
	:silent clast
	:redir END
	:silent cfirst
	:echo strpart(l:message, 1)
endfunction

" ack
function! Ack(string)
	if a:string=="ask"
		let l:string = input("Ack: ")
	else
		let l:string = a:string
	endif
	let &grepprg="ack " . l:string
	silent grep
	redraw!
	copen
endfunction

" ToggleComment
function! ToggleComment(visual)
	if (&ft=='c'||&ft=='cpp')
		let l:c_sign='//'
	elseif (&ft=='sh'||&ft=='conf'||&ft=='config'||&ft=='cmake'||&ft=='zsh')
		let l:c_sign='#'
	elseif (&ft=='tex')
		let l:c_sign='%'
	elseif (&ft=='vim')
		let l:c_sign='"'
	endif
	if !exists("l:c_sign")
		echo "ToggleComment(): Filetype not supported!"
		return
	endif

	if a:visual=='true'
		exe 'normal! gv'
		let l:lines=[line('v'), line('.')]
		exe 'normal! "_y'
		function! NumSort(i1, i2)
			return a:i1==a:i2?0: a:i1>a:i2?1:-1
		endfunc
		let lines = sort(lines, "NumSort")
	else
		let l:lines=[line('.'), line('.')]
	endif

	for l:line in reverse(range(l:lines[0], l:lines[1]))
		if getline(l:lines[0])=~ '^\s*'.l:c_sign
			call setline(l:line, substitute(getline(l:line), '\(^\s*\)'.l:c_sign, '\1', "g"))
		else
			call setline(l:line, substitute(getline(l:line), '\(^\s*\)\([^$]\)', '\1'.l:c_sign.'\2', "g"))
		endif
	endfor
endfunction

" Switch between source/header
function! SwitchHS()
	let l:e=expand('%:e')
	try
	if l:e=~'^c'
		find **/%:t:r.h*
	elseif l:e=~'^h'
		find **/%:t:r.c*
	endif
	catch /.*/
		echo v:exception
	endtry
endfunction

" Toggle colorcolumn
function! ToggleColorColumn()
	if &colorcolumn>0
		set colorcolumn=0
	else
		if !(&textwidth==0)
			let &colorcolumn=&textwidth
		else
			set colorcolumn=80
		endif
	endif
endfunction
