" .vimrc
"
" VUNDLE
"
set nocompatible
filetype off
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" manage self
Plugin 'gmarik/vundle'

" bundles
Plugin 'bufexplorer.zip'
Plugin 'gnupg'
Plugin 'ervandew/supertab'
Plugin 'tpope/vim-fugitive'
Plugin 'airblade/vim-gitgutter'
Plugin 'valloric/youcompleteme'
Plugin 'junegunn/fzf', {'do': './install --all'}
Plugin 'junegunn/fzf.vim'

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

" fixes
 "disable 'raw'-mode (check 'terminal-options' and 'modifyOtherKeys') for no
 "fully xterm compliant terminals (i.e., gnome-terminal), otherwise raw
 "characters will be printed to terminal a lot
set t_TE= t_TI=

" format
set autoindent		" indent current line -> indent new line
set encoding=utf-8	" character encoding
set shiftwidth=4	" # of (auto)indent spaces
set smartindent		" smarter than cindent
set smarttab		" use shiftwidth for ^line tabs
set softtabstop=4	" while (editing) tab = width of # spaces
set tabstop=4		" tab = width of # spaces
set updatetime=100  " update window (and swap)

" search/substitute
set gdefault	" default to global substitution
set hlsearch	" if (previous search pattern) highlight all matches
set ignorecase	" if (captain obvious is here) ignore comment
set incsearch	" while (typing search pattern) jump to first match
set magic		" magic chars in search pattern
set smartcase	" if (pattern has upper case char) ignore ignorecase

" statusline
set statusline=%<%{FugitiveStatusline()}						" git status from fugitive
set statusline+=\ 												" space
set statusline+=%f\ %h%m%r%w									" file [help][modify][readonly][preview]
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
	au BufDelete,ExitPre */.logbook/* call LogBook("close")
	au BufNew * set foldlevel=20
	au BufReadPost fugitive://* set bufhidden=delete
	au BufReadPost * silent! normal '"
	au BufLeave * let b:winview = winsaveview()
	au BufEnter * if(exists('b:winview')&&!&diff)|call winrestview(b:winview)|endif
	au BufRead,BufNewFile *.dox setfiletype doxygen
	au BufRead,BufNewFile *.launch setfiletype roslaunch
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
vnoremap < <gv
vnoremap > >gv
nnoremap / /\v
vnoremap / /\v
nnoremap zO zCzO

" arrow keys (disabled -> hjkl)
nnoremap j gj
nnoremap k gk
nnoremap <up> <nop>
nnoremap <down> <nop>
nnoremap <left> <nop>
nnoremap <right> <nop>
inoremap <up> <nop>
inoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>

" leader...
nnoremap <silent> <leader>/ :execute 'vimgrep /'.@/.'/g %'<cr>:copen<cr>
nnoremap <silent> <leader>at :call Ack("TODO")<cr>
nnoremap <silent> <leader>aa :call Ack("ask")<cr>

" comments
nnoremap <leader>c :<c-u>call ToggleComment('false')<cr>
vnoremap <leader>c :<c-u>call ToggleComment('true')<cr>

nnoremap <leader>C :let &colorcolumn = &colorcolumn>0 ? 0 : &textwidth==0 ? 100 : &textwidth<cr>

" git mergetool
nnoremap <leader>dr :diffget REMOTE<cr>
nnoremap <leader>db :diffget BASE<cr>
nnoremap <leader>dl :diffget LOCAL<cr>

nnoremap <leader>D :call NetrwToggle($PWD)<cr>
nnoremap <leader>ev <c-w><c-v><c-l>:e $MYVIMRC<cr>

" fzf
nnoremap <leader>bb :Buffers<cr>
nnoremap <leader>fa :Ag<cr>
nnoremap <leader>fc :BCommits<cr>
nnoremap <leader>fC :Commits<cr>
nnoremap <leader>ff :FZF<cr>
nnoremap <leader>fg :GFiles?<cr>
nnoremap <leader>fh :History:<cr>
nnoremap <leader>fm :Maps<cr>
nnoremap <leader>fr :Rg<cr>
nnoremap <leader>fw :Windows<cr>

" fugitive & git-gutter
map <leader>gb :Git blame<cr>
map <leader>gc :Git commit<cr>
map <leader>gd :Gdiffsplit<cr>
map <leader>ge :Gedit HEAD<cr>
map <leader>gf :Git fetch<cr>
map <silent> <leader>gg :GitGutterQuickFix<cr><cr><cr>:QFix<cr>
map <leader>gl :Gclog<cr><cr><cr>:QFix<cr>
map <leader>gp :Git push<cr>
map <leader>gr :Gread<cr>
map <leader>gs :Git<cr>
map <leader>gw :Gwrite<cr>

nnoremap <leader>hh :call SwitchHS()<cr>

" make
map <silent> <leader>ma :call Make("all")<cr>
map <silent> <leader>mc :call Make("clean")<cr>
map <silent> <leader>md :call Make("debug")<cr>
map <silent> <leader>mi :call Make("install")<cr>
map <silent> <leader>mm :call Make(" ")<cr>
map <silent> <leader>mr :call Make("run")<cr>
map <silent> <leader>mv :call Make("VERBOSE=1")<cr>

" logbook
nnoremap <leader>lb :call LogBook("logbook")<cr>
nnoremap <leader>lc :call LogBook("close")<cr>
nnoremap <leader>lo :call LogBook("")<cr>

nnoremap <leader>ll :set list!<cr>:set list?<cr>
nnoremap <leader>n :let [&number, &relativenumber] = [!&relativenumber, &number+&relativenumber==1]<cr>
nnoremap <leader>N :nohlsearch<cr>
nnoremap <leader>p :pclose<cr>

nnoremap <leader>ss :set spell!<cr>:set spell?<cr>
nnoremap <leader>sw :w !sudo tee %<cr>
nnoremap <leader>S :if exists("g:syntax_on")<Bar>syntax off<Bar>else<Bar>syntax enable<Bar>endif<cr>

" quickfix
map <silent> <leader><space> :QFix<cr>
map <silent> <leader>qc :cc<cr>
map <silent> <leader>qn :cnext<cr>
map <silent> <leader>qp :cprev<cr>

" (c)tags & terminal
nnoremap <leader>tg :!ctags --recurse --exclude=.git -f `git dir`/.git/tags &>/dev/null `git dir` &<cr>
nnoremap <leader>tl :tselect<cr>
nnoremap <leader>tn :tnext<cr>
nnoremap <leader>tp :tprev<cr>
nnoremap <leader>ts :tags<cr.
nnoremap <leader>tt :terminal<cr>

nnoremap <leader>v  <c-O>:set paste<cr><c-r>*<c-O>:set nopaste<cr>
nnoremap <leader>wo :call ToggleSplitZoom()<cr>
nnoremap <leader>W :%s/\s\+$//<cr>:let @/=''<cr>

" ycm
nnoremap <leader>yd :YcmCompleter GoToDefinition<cr>
nnoremap <leader>yD :YcmCompleter GoToDeclaration<cr>
nnoremap <leader>yi :YcmCompleter GoToInclude<cr>
nnoremap <leader>yg :YcmCompleter GoTo<cr>
nnoremap <leader>yG :YcmCompleter GoToImprecise<cr>
nnoremap <leader>yh :YcmCompleter GetDoc<cr>
nnoremap <leader>yH :YcmCompleter GetDocImprecise<cr>
nnoremap <leader>yf :YcmCompleter FixIt<cr>
nnoremap <leader>yr :YcmCompleter GoToReferences<cr>
nnoremap <leader>yR :YcmCompleter RefactorRename 
nnoremap <leader>ys :YcmShowDetailedDiagnostic<cr>
nnoremap <leader>yS :YcmDiags<cr>
nnoremap <leader>yt :YcmCompleter GetType<cr>
nnoremap <leader>yT :YcmCompleter GetTypeImprecise<cr>

"
" COLOR
"
hi ColorColumn	ctermbg=black
hi Pmenu		ctermbg=black		ctermfg=brown	cterm=none
hi PmenuSel		ctermbg=red			ctermfg=black	cterm=none
hi PmenuSbar	ctermbg=darkgrey					cterm=none
hi PmenuThumb	ctermbg=yellow						cterm=none
hi Search		ctermbg=black		ctermfg=red

"
" PLUGINS
"
" fugitive
set tags^=.git/tags;~ " prevent fugitive to complain about tag file

" git-gutter
let g:gitgutter_realtime = 1
let g:gitgutter_max_signs = 500 " default, might need to increase
let g:gitgutter_sign_added = '±'
let g:gitgutter_sign_modified = '±'
let g:gitgutter_sign_removed = '±'
let g:gitgutter_sign_removed_first_line = '±‾'
let g:gitgutter_sign_modified_removed = '±‾'
hi GitGutterAdd				ctermfg=green	cterm=bold
hi GitGutterChange			ctermfg=yellow	cterm=bold
hi GitGutterDelete			ctermfg=red		cterm=bold
hi GitGutterChangeDelete	ctermfg=yellow	cterm=bold

" ycm
let g:ycm_always_popule_location_list = 1
let g:ycm_auto_trigger = 1
let g:ycm_clangd_uses_ycmd_caching = 0
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
	elseif &ft == 'tex' || &ft == 'plaintex'
		set makeprg=pdflatex\ %
	elseif expand('%:p')=~'/workspace/'
		let l:path=expand('%:h')
		let l:base=system('catkin config | awk "/Build Space:/ { printf \"%s\",\$4 }"')
		while l:path!='.'
			let l:build=fnamemodify(l:base, ":p").fnamemodify(l:path, ":t")
			if isdirectory(l:build)
				let &makeprg="(cd ".l:build." && make " . a:target . ")"
				break
			endif
			let l:path=fnamemodify(l:path, ':h')
		endwhile
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
	if (&ft=~'^c\($\|pp\|uda\)') | let l:c_sign='//'
	elseif (&ft=='css') | let l:c_begin='/\*' | let l:c_end='\*/'
	elseif (&ft=~'doxygen\|html\|markdown\|roslaunch\|xml') | let l:c_begin='<!--' | let l:c_end='-->'
	elseif (&ft=='groovy') | let l:c_sign='//'
	elseif (&ft=='haskell') | let l:c_sign='--'
	elseif (&ft=='matlab') | let l:c_sign='%'
	elseif (&ft=~'^\(\|plain\)tex\|^bib') | let l:c_sign='%'
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
				call setline(l:line, substitute(getline(l:line), '\(^\s*\)\([^\n]\)', '\1'.l:c_sign.'\2', "g"))
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
		for suffix in ['', l:n, 'pp', 'xx', '++', 'u']
			try
				execute 'find '.path.'/%:t:r.'.l:n.suffix
			catch /^Vim(find):E345:/
				continue
			catch /^Vim(find):E77/
				" handle multiple matches, use first (path up/down) match
				execute 'edit '.findfile(expand('%:t:r').'.'.l:n.suffix, '**,./**', 0)
				break
			catch /.*/
				"echo v:exception
				continue
			endtry
			break
		endfor
	endfor
endfunction

function! LogBook(mode)
	" TODO register hooks for open/closing files within ~/.logbook
	" TODO default action: open .logbook/log.md and jump to bottom?
	" TODO index links to other files found in .logbook/?
	" TODO move git_dir check to outer logic
	" TODO handle no network and other pull/commit/push issues
	let l:base = expand("~/.logbook/")
	silent! system('cd '.l:base.'; git pull origin')
	if isdirectory(l:base)
		if empty(a:mode)
			execute "FZF ".l:base
		elseif a:mode == "close"
			let l:git_dir = system('cd '.l:base.'; git rev-parse --show-toplevel --sq')
			if l:git_dir =~ l:base
				let l:stat = system('cd '.l:base.'; git diff --numstat | awk "{print \$3\$4\$5\":+\"\$1\"-\"\$2; }"')
				let l:host = system('hostname -s')
				echo system('cd '.l:base.'; git commit --all --message "['.l:host.'] '.l:stat.'"')
				echo system('cd '.l:base.'; git push origin')
			else
				echo "No git directory in ".l:base." found!"
			endif
			quit
		else
			execute 'vsplit '.l:base.a:mode.'.md'
		endif

	else
		echo "Cannot find ".l:base."!"
	endif
endfunction
