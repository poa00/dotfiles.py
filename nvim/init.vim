"
"  _   _         __     ___
" | \ | | ___  __\ \   / (_)_ __ ___
" |  \| |/ _ \/ _ \ \ / /| | '_ ` _ \
" | |\  |  __/ (_) \ V / | | | | | | |
" |_| \_|\___|\___/ \_/  |_|_| |_| |_|
"
"
" Specify directory for plugins: VERY IMPORTANT TO USE SINGLE QUOTES
call plug#begin('$VIMPLUGINS')
    " Basic Options
    set nocompatible
    set t_Co=256
    set fileformat=unix

    " Appearance
    set nu relativenumber
    set scrolloff=3
    set noshowmode nowrap
    set ttyfast

    " Behaviour
    set splitright splitbelow
    set mouse=a " a for all
    set clipboard=unnamedplus
    set noswapfile
    set nofoldenable
    set path+=**
    set timeoutlen=400

    " Abbreviaton
    abbr slef self
    abbr cosntants constants
    abbr unkown unknown
    abbr clas class
    abbr __clas__ __class__

    augroup ConfigGroup
        autocmd!
        " Save on focus lost
        autocmd FocusLost * silent! wa
        " Enable/disable cursorline when focus is lost/gained
        autocmd WinEnter * set cursorline
        autocmd WinLeave * set nocursorline
        " Set Filetypes
        autocmd BufRead,BufNewFile *.har set filetype=json
        autocmd BufRead,BufNewFile .zshrc,oh_my_zshrc set filetype=zsh
        autocmd FileType yaml,json,html set shiftwidth=2 tabstop=2 softtabstop=2
        " Format JSON files with jq
        autocmd BufWrite *.json execute ':%!jq'
    augroup END

    " Python configuration for tabs and spaces and all that
    set expandtab smartindent
    set tabstop=4 " the visible width of tabs
    set softtabstop=4 " edit as if the tabs are 4 characters wide
    set shiftwidth=4 " number of spaces to use for indent and unindent
    set shiftround " round indent to a multiple of 'shiftwidth'

    " Mappings
    let mapleader = ','
    nmap <leader>w :w<CR>
    nmap <leader>q :q!<CR>
    nmap <leader>e :wq!<CR>
    nmap <leader>t :tabnew <CR>
    nnoremap <leader>r :source $VIMRC<CR>
    nnoremap <silent> <space> :noh<CR>
    nnoremap <silent> ^ g^
    nnoremap <silent> 0 g0
    nnoremap <silent> $ g$
    nnoremap <silent> <C-e> 3<c-e>
    nnoremap <silent> <C-y> 3<c-y>
    nnoremap <silent> <BS> <c-^>
    " Keep in vsual mode after indentation
    vmap <silent> < <gv
    vmap <silent> > >gv

    " More natural split navigation
    nnoremap <C-l> <C-W>l
    nnoremap <C-k> <C-W>k
    nnoremap <C-j> <C-W>j
    nnoremap <C-h> <C-W>h

    " Terminal splitting
    autocmd TermOpen * setlocal nonumber norelativenumber
    autocmd TermOpen * startinsert

    nnoremap <silent> <c-w>tv <c-w>v :term<CR>
    nnoremap <silent> <c-w>ts <c-w>s :term<CR>
    " Move from withing the terminal split
    tnoremap <silent> <c-h> <c-\><c-n><c-w><c-h>
    tnoremap <silent> <c-j> <c-\><c-n><c-w><c-j>
    tnoremap <silent> <c-k> <c-\><c-n><c-w><c-k>
    tnoremap <silent> <c-l> <c-\><c-n><c-w><c-l>
    tnoremap <silent> <ESC> <c-\><c-n>

    " Options for vim-plug
    let g:plug_pwindow = 'vertical rightbelow new'

    " General plugins
    Plug 'arcticicestudio/nord-vim'
        let g:nord_cursor_line_number_background = 1
        let g:nord_uniform_diff_background = 1
        let g:nord_bold = 1 " Default
        let g:nord_italic = 1
        let g:nord_underline = 1

        augroup nord-theme-overrides
            autocmd!
            autocmd ColorScheme nord highlight Comment ctermfg=DarkGrey
        augroup END

    Plug 'vim-airline/vim-airline'
        let g:airline#extensions#hunks#enabled = 0
        let g:airline#extensions#poetv#enabled = 1

        let g:airline_section_x = '%{PencilMode()}'
        let g:airline_powerline_fonts = 1
        let g:airline#extensions#tabline#enabled = 0

    if has('nvim')
        Plug 'mhinz/vim-startify'
            autocmd User Startified setlocal cursorline

            " Don't change to directory when selecting a file
            let g:startify_files_number = 5
            let g:startify_change_to_dir = 0
            let g:startify_relative_path = 1
            let g:startify_use_env = 1

            function! s:list_commits()
                let git = 'git -C ' . getcwd()
                let commits = systemlist(git . ' log --oneline | head -n5')
                let git = 'G' . git[1:]
                return map(commits, '{"line": matchstr(v:val, "\\s\\zs.*"), "cmd": "'. git .' show ". matchstr(v:val, "^\\x\\+") }')
            endfunction

            " Custom startup list, only show MRU from current directory/project
            let g:startify_lists = [
                \  { 'type': 'dir',       'header': [ 'Files '. getcwd() ] },
                \  { 'type': function('s:list_commits'), 'header': [ 'Recent Commits' ] },
                \  { 'type': 'sessions',  'header': [ 'Sessions' ] },
                \  { 'type': 'bookmarks', 'header': [ 'Bookmarks' ] },
                \  { 'type': 'commands',  'header': [ 'Commands' ] },
            \ ]

            let g:startify_commands = [
                \   { 'up': [ 'Update Plugins', ':PlugUpdate' ] },
                \   { 'ug': [ 'Upgrade Plugin Manager', ':PlugUpgrade' ] },
            \ ]
    endif

    Plug 'scrooloose/nerdtree', {'on': ['NERDTreeToggle', 'NERDTreeFind']}
        " Close vim if NERDTree is the only window
        let g:NERDTreeWinPos = "right"
        let NERDTreeQuitOnOpen = 1
        let NERDTreeAutoDeleteBuffer = 1
        let NERDTreeMinimalUI = 1
        let NERDTreeDirArrows = 1
        let NERDTreeShowHidden = 1
        let NERDTreeIgnore = ['\.pyc$', '__pycache__/', '.git/', '\.swp$']

        nnoremap <silent> \\ :NERDTreeToggle<CR>

        " Close NERDTree if it's the last window open
        autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
        " Make sure no window can be open in the NERDTree window
        autocmd BufEnter * if bufname('#') =~# "^NERD_tree_" && winnr('$') > 1 | b# | endif
        " turn off whitespace characters and turn off line highlighting for performance
        augroup nerdtree
            autocmd!
            autocmd FileType nerdtree setlocal nolist " turn off whitespace characters
            autocmd FileType nerdtree setlocal nocursorline " turn off line highlighting for performance
        augroup END

    Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
    Plug 'ryanoasis/vim-devicons'

    Plug '/usr/bin/fzf'
    Plug 'junegunn/fzf.vim'
        let g:fzf_layout = { 'down': '~30%' }
        let g:fzf_commits_log_options = '--graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr"'

        if has('nvim')
            let $FZF_DEFAULT_OPTS .= ' --inline-info'
        endif

        command! -bang -nargs=* GGrep
            \ call fzf#vim#grep(
            \   'git grep --line-number '.shellescape(<q-args>), 0,
            \   fzf#vim#with_preview({'dir': systemlist('git rev-parse --show-toplevel')[0]}), <bang>0)

        autocmd! FileType fzf
        autocmd  Filetype fzf set noshowmode noruler nonu

        nnoremap <leader>b :Buffers<CR>

        " Git plugins: Only load when we are in a git repo.
        if isdirectory(".git")
            nnoremap <leader>f :GitFiles --cache --others --exclude-standard<CR>
            nnoremap <leader>g :GGrep<CR>
            nnoremap <leader>c :BCommits<CR>

            " Add JIRA issue to commit message. Only load these for gitcommit
            " filetype
            " TODO: Investigate how to run this automagically
            au FileType gitcommit nnoremap <leader>g :normal 5gg5wy$ggp<CR>a
            au FileType gitcommit nnoremap <leader>b :normal 5gg3wy$ggp<CR>a

            Plug 'tpope/vim-fugitive'
            Plug 'mhinz/vim-signify'
            Plug 'Xuyuanp/nerdtree-git-plugin'

            Plug 'rhysd/git-messenger.vim'
                let g:git_messenger_no_default_mappings = v:true
                let g:git_messenger_include_diff = 'current'
                let g:git_messenger_always_into_popup = v:true

                nmap gm <Plug>(git-messenger)

            Plug 'sodapopcan/vim-twiggy'
                let g:twiggy_remote_branch_sort = 'date'

                nnoremap \t :Twiggy<CR>
        else
            nnoremap <leader>f :FZF<CR>
        endif

    Plug 'Yggdroot/indentLine'
        let g:indentLine_char_list = ['|', '¦', '┆', '┊']

    Plug 'junegunn/rainbow_parentheses.vim'
        let g:rainbow#pairs = [['(', ')'], ['[', ']'], ['{', '}']]

        augroup rainbow
            autocmd!
            autocmd FileType * RainbowParentheses
        augroup END

    Plug 'junegunn/vim-peekaboo'
        let g:peekaboo_window = 'vert bo 60new'

    Plug 'junegunn/vim-slash'
        noremap <plug>(slash-after) zz
        if has('timers')
            " Blink 2 times with 50ms interval
            noremap <expr> <plug>(slash-after) slash#blink(2, 50)
        endif

    Plug 'dominikduda/vim_current_word'
        let g:vim_current_word#highlight_delay = 1000

    " TODO: Mapping dictionary with key explanations
    Plug 'liuchengxu/vim-which-key', { 'on': ['WhichKey', 'WhichKey!'] }
        nnoremap <silent> <leader> :WhichKey ','<CR>
        nnoremap <silent> \ :WhichKey '\'<CR>

    Plug 'tpope/vim-commentary'
    Plug 'tpope/vim-repeat'
    Plug 'tpope/vim-surround'
    Plug 'tpope/vim-unimpaired'

    " Programming plugins
    Plug 'ycm-core/YouCompleteMe', {'do': 'python3 ./install.py --rust-completer'}
        let g:ycm_autoclose_preview_window_after_insertion = 1
        let g:ycm_min_num_of_chars_for_completion = 2
        let g:ycm_collect_identifiers_from_comments_and_strings = 1
        let g:ycm_seed_identifiers_with_syntax = 1

        nnoremap <silent> <leader>d :YcmCompleter GoTo<CR>
        nnoremap <silent> <leader>s :YcmCompleter GoToReferences<CR>
        nnoremap <silent> <leader>k :YcmCompleter GetDoc<CR>

    Plug 'dense-analysis/ale'
        let g:airline#extensions#ale#enabled = 1

        let g:ale_lint_on_text_changed = 'never'
        let g:ale_lint_on_insert_leave = 0

        let g:ale_linters_explicit = 1
        let g:ale_linters = {'python': ['flake8']}

        let g:ale_set_loclist = 1
        let g:ale_fix_on_save = 1

        let g:ale_fixers = {
            \ '*': ['trim_whitespace', 'remove_trailing_lines'],
            \ 'python': ['isort', 'black'],
        \ }

        let g:ale_python_black_options = '--line-length $PYTHON_LINE_LENGTH --target-version py37'

        nmap <silent> ]l :ALENextWrap<CR>
        nmap <silent> [l :ALEPreviousWrap<CR>

        " Docstring autoformatter
        function! <SID>format_docstrings()
            let l = line(".")
            let c = col(".")
            %!docformatter -c --wrap-summaries $PYTHON_LINE_LENGTH --wrap-descriptions $PYTHON_LINE_LENGTH -
            call cursor(l, c)
        endfun

        nnoremap \ds :call <SID>format_docstrings()<CR>

    " Language specific plugins
    Plug 'petobens/poet-v'
        let g:poetv_executables = ['poetry']

    Plug 'gabrielelana/vim-markdown', {'for': ['md', 'rst']}
        " TODO: Plug 'plasticboy/vim-markdown' " Maybe it's an alternative to the above plugin
        let g:pencil#autoformat = 1
        let g:pencil#textwidth = $TEXT_LINE_LENGTH

    Plug 'lervag/vimtex', {'for': 'text'} " Latex in Vim
        " TODO: Look at the mappings and configs for this

    Plug 'cespare/vim-toml'
    Plug 'Glench/Vim-Jinja2-Syntax'
    Plug 'ekalinin/Dockerfile.vim', {'for': 'Dockerfie'}
    Plug 'rust-lang/rust.vim', {'for': 'rs'}
        let g:rustfmt_autosave = 1

    " Writer's room:
    Plug 'junegunn/goyo.vim' " 0 Distractions
        let g:goyo_width = $TEXT_LINE_LENGTH
        " TODO: Configuations

    Plug 'reedes/vim-pencil' " Turn VIM into a good writing editor.
        " TODO: Configure both GOYO and Pencil to trigger automatically for MD, RST, TXT, etc... files.

    " Only load these plugins when inside tmux"
    if (exists("$TMUX"))
        Plug 'justinmk/vim-gtfo'
        Plug 'christoomey/vim-tmux-navigator'
            let g:tmux_navigator_save_on_switch = 1
            let g:tmux_navigator_disable_when_zoomed = 1
            let g:tmux_navigator_no_mappings = 1

            nnoremap <silent> <c-h> :TmuxNavigateLeft<cr>
            nnoremap <silent> <c-j> :TmuxNavigateDown<cr>
            nnoremap <silent> <c-k> :TmuxNavigateUp<cr>
            nnoremap <silent> <c-l> :TmuxNavigateRight<cr>

        Plug 'tmux-plugins/vim-tmux-focus-events'
        Plug 'wellle/tmux-complete.vim'
    endif

call plug#end() " Finished Initialising Plugins

" Set the colorscheme
set background=dark
colorscheme nord
