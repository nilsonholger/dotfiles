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
Bundle 'gnupg'
Bundle 'ervandew/supertab'
Bundle 'tpope/vim-fugitive'
Bundle 'Valloric/YouCompleteMe'

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
set nomodeline									" dis-allow vim modelines
set modelines=0									" process #lines of modeline commands
set mouse=n										" clicketyclick
"set scrolloff=3									" always display #lines context
set showcmd										" display partial commands
set whichwrap=<,>,[,],h,l						" can move to next/previous line

" display
set conceallevel=2		" simply because
set fileformats+=mac	" cause we workin' on the fruity stuff
set foldmethod=syntax	" yes, we like folds, especially intelligent ones
set linebreak			" wrap looooooong lines
set list				" show listchars (see below)
set listchars=tab:\.\ ,trail:_,extends:>,precedes:<
set number				" show line numbers as default
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

" undofile
set undofile
set undodir=~/.vim/undo

" wildmenu
set wildmenu
"set wildmode=list:longest
set wildignore+=.hg,.git,.svn						" Version control
set wildignore+=*.aux,*.out,*.toc					" LaTeX intermediate files
set wildignore+=*.jpg,*.bmp,*.gif,*.png,*.jpeg		" binary images
set wildignore+=*.o,*.obj,*.exe,*.dll,*.manifest	" compiled object files
set wildignore+=*.spl								" compiled spelling word lists
set wildignore+=*.sw?								" Vim swap files
set wildignore+=*.DS_Store							" OSX bullshit

" various
let g:changelog_username = "NilsonHolger <nilsonholger@hyve.org>"
let g:netrw_banner = 0						" remove superfluous banner (show with 'I')
let g:netrw_liststyle = 3					" use tree view
let g:netrw_winsize = -40					" use fixed split width
let g:netrw_browse_split = 4				" open in prev window
let g:netrw_list_hide= '.*\.swp$,.*\.swo$'	" hide vim temp files

"
" AUTOCOMMAND
"
if has("autocmd")
	filetype plugin indent on
	au BufNew * set foldlevel=20
	au BufReadPost fugitive://* set bufhidden=delete
	au BufReadPost * silent! normal '"
	au BufLeave * let b:winview = winsaveview()
	au BufEnter * if(exists('b:winview')&&!&diff)|call winrestview(b:winview)|endif
	au! BufWritePost $MYVIMRC windo source $MYVIMRC
	au CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif
	au FileType conf setfiletype config
	au FileType matlab set expandtab| set ts=2| set sw=2
	au VimEnter * silent if filereadable("Session.vim") | source Session.vim | endif
	au VimLeave * silent if filereadable("Session.vim") | mksession! Session.vim | endif
	au VimResized * exe "normal! \<c-w>="
endif

"
" MAPS
"
" general
let mapleader=' ' " normally mapped to <Right>, not really useful
nnoremap <leader>c :<c-u>call ToggleComment('false')<cr>
vnoremap <leader>c :<c-u>call ToggleComment('true')<cr>
nnoremap <leader>C :let &colorcolumn = &colorcolumn>0 ? 0 : &textwidth==0 ? 80 : &textwidth<cr>
nnoremap <leader>D :call NetrwToggle($PWD)<CR>
nnoremap <leader>ev <C-w><C-v><C-l>:e $MYVIMRC<CR>
nnoremap <leader>h :call SwitchHS()<cr>
nnoremap <leader>l :set list!<CR>:set list?<CR>
nnoremap <leader>n :let [&number, &relativenumber] = [!&relativenumber, &number+&relativenumber==1]<CR>
nnoremap <leader>N :nohlsearch<CR>
nnoremap <leader>ss :set spell!<CR>:set spell?<CR>
nnoremap <leader>S :if exists("g:syntax_on")<Bar>syntax off<Bar>else<Bar>syntax enable<Bar>endif<CR>
nnoremap <leader>sw :w !sudo tee %<CR>
nnoremap <leader>v  <C-O>:set paste<CR><C-r>*<C-O>:set nopaste<CR>
nnoremap <leader>wo :call ToggleSplitZoom()<cr>
nnoremap <leader>W :%s/\s\+$//<CR>:let @/=''<CR>
nnoremap / /\v
vnoremap / /\v
nnoremap <silent> <leader>/ :execute 'vimgrep /'.@/.'/g %'<CR>:copen<CR>
nnoremap zO zCzO
vnoremap < <gv
vnoremap > >gv

" arrow keys (disabled -> hjkl)
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

" quickfix
map <silent> <leader><space> :QFix<CR>
map <silent> <leader>qc :cc<CR>
map <silent> <leader>qn :cnext<CR>
map <silent> <leader>qp :cprev<CR>

" make
map <silent> <leader>ma :call Make("all")<CR>
map <silent> <leader>mc :call Make("clean")<CR>
map <silent> <leader>md :call Make("debug")<CR>
map <silent> <leader>mi :call Make("install")<CR>
map <silent> <leader>mm :call Make(" ")<CR>
map <silent> <leader>mr :call Make("run")<CR>
map <silent> <leader>mv :call Make("VERBOSE=1")<CR>

" search
map <silent> <leader>at :call Ack("TODO")<CR>
map <silent> <leader>aa :call Ack("ask")<CR>

" fugitive
map <leader>gb :Gblame<CR>
map <leader>gc :Gcommit<CR>
map <leader>gd :Gdiff<CR>
map <leader>ge :Gedit HEAD<CR>
map <leader>gl :Glog<CR><CR><CR>:QFix<CR>
map <leader>gp :Gpull<CR>
map <leader>gr :Gread<CR>
map <leader>gs :Gstatus<CR>
map <leader>gu :Gpush<CR>
map <leader>gw :Gwrite<CR>

"
" COLOR
"
hi Pmenu		ctermbg=black		ctermfg=brown	cterm=none
hi PmenuSel		ctermbg=red			ctermfg=black	cterm=none
hi PmenuSbar	ctermbg=darkgrey					cterm=none
hi PmenuThumb	ctermbg=yellow						cterm=none
hi Search		ctermbg=black		ctermfg=red

"
" PLUGINS
"
" ycm
let g:ycm_global_ycm_extra_conf = '~/.vim/ycm_extra_conf.py'

" supertab
let g:SuperTabDefaultCompletionType = "context"

" vimwiki
let g:vimwiki_list = [{'path': '~/.org/'}]
let g:vimwiki_folding = 1
let g:vimwiki_fold_lists = 1

"
" FUNCTIONS
"
" toggle netrw window
let g:netrw_open=0
function! NetrwToggle(directory)
	if g:netrw_open
		let l:buf = bufnr("$")
		while (l:buf >= 1)
			if (getbufvar(l:buf, "&filetype") == "netrw") | silent exe "bwipeout " . l:buf | endif
			let l:buf-=1
		endwhile
		let g:netrw_open=0
	else
		silent exe "Lexplore " . a:directory
		let g:netrw_open=1
	endif
endfunction

" toggle splits
function! ToggleSplitZoom()
	let l:session = "/tmp/session.".getpid().".vim"
	let l:sessionoptions=&sessionoptions
	set sessionoptions="blank,folds,help,winsize"
	if filereadable(l:session)
		silent exe "source" l:session
		exe "call delete('".l:session."')"
	else
		exe "mksession!" l:session
		exe "normal \<C-W>o"
	endif
	exe 'set' 'sessionoptions='.l:sessionoptions
endfunction

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
	elseif &ft == 'tex' || ft == 'plaintex'
		set makeprg=pdflatex\ %
	endif
	silent w
	silent make!
	redraw!
	redir => l:message
	silent! clist! -1
	redir END
	echo strpart(l:message, 1)
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
	if (&ft=~'^c\($\|pp\)') | let l:c_sign='//'
	elseif (&ft=='css') | let l:c_begin='/\*' | let l:c_end='\*/'
	elseif (&ft=~'^\(\|plain\)tex\|^bib') | let l:c_sign='%'
	elseif (&ft=='haskell') | let l:c_sign='--'
	elseif (&ft=='html') | let l:c_begin='<!--' | let l:c_end='-->'
	elseif (&ft=='matlab') | let l:c_sign='%'
	elseif (&ft=='vim') | let l:c_sign='"'
	else | let l:c_sign='#'
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

	if exists('l:c_sign')
		for l:line in reverse(range(l:lines[0], l:lines[1]))
			if getline(l:lines[0])=~ '^\s*'.l:c_sign
				call setline(l:line, substitute(getline(l:line), '\(^\s*\)'.l:c_sign, '\1', "g"))
			else
				call setline(l:line, substitute(getline(l:line), '\(^\s*\)\([^$]\)', '\1'.l:c_sign.'\2', "g"))
			endif
		endfor
	else
		if getline(l:lines[0])=~ '^\s*'.l:c_begin
			call setline(l:lines[0], substitute(getline(l:lines[0]), '\(^\s*\)'.l:c_begin, '\1', "g"))
			call setline(l:lines[1], substitute(getline(l:lines[1]), '\(^.\{-}\)'.l:c_end, '\1', "g"))
		else
			call setline(l:lines[0], substitute(getline(l:lines[0]), '\(^\s*\)\([^$]\)', '\1'.l:c_begin.'\2', "g"))
			call setline(l:lines[1], substitute(getline(l:lines[1]), '$', l:c_end, "g"))
		endif
	endif
endfunction

" Switch between header/source: *.((h|hh|c|cc)|(h|c)(pp|xx|++))
function! SwitchHS()
	let [l:e, l:n] = [expand('%:e'), ""]
	if l:e=~'^c' | let l:n="h" | elseif l:e=~'^h' | let l:n="c" | endif
	for path in ['%:p:h', '**']
		for suffix in ['', l:n, 'pp', 'xx', '++']
			try
				execute 'find '.path.'/%:t:r.'.l:n.suffix
			catch /.*/
				continue
			endtry
			break
		endfor
	endfor
endfunction
