# Settings and functions for FZF

# Shell key bindgins for fedora systems
[[ "$(uname -r | grep -oP 'fc\d{2}')" ]] && source /usr/share/fzf/shell/key-bindings.zsh

# Setting fd as the default source for fzf
export FZF_DEFAULT_COMMAND='fd'

# Default options for all fzf calls
export FZF_DEFAULT_OPTS="--ansi --reverse --border --height 80% --exact"

# To apply the command to CTRL-T as well
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# source: https://junegunn.kr/2016/07/fzf-git/
is-in-git-repo() {
    git rev-parse --is-inside-work-tree &>/dev/null
}

# Default FZF opts and parameters
-fzf-custom-window() {
    local query
    [[ "$querystring" ]] && query="-q ${querystring}"
    fzf-tmux --exit-0 --select-1 --preview "$preview_cmd" $query "$@"
}

-fzf-git-restore_files() {
    git status -s | grep -oP "$RE_FILES" | -fzf-custom-window --header "Select a file" --layout=reverse -m --preview-window=right:80%
}

-fzf-git-choose-branch() {
    local preview_cmd='git lol --color=always -20 {+1}'
    git branch --list | grep -oP "^\s+\K.+$" | -fzf-custom-window --header "Select a branch" --height 80% --preview-window=down:75%
}

# source: https://github.com/junegunn/fzf/wiki/Examples#tmux
# tm - create new tmux session, or switch to existing one. Works from within tmux too. (@bag-man)
# `tm` will allow you to select your tmux session via fzf.
# `tm irc` will attach to the irc session (if it exists), else it will create it.

if [ "$(command -v tmux)" ]; then
    tm() {
        local TMUX_CONFIG=$DOTFILES/tmux/tmux.conf
        local session
        session=$1
        [[ -n $TMUX ]] && change="switch-client" || change="attach-session"
        if [ "$session" ]; then
            tmux -f "$TMUX_CONFIG" "$change" -t "$1" 2>/dev/null ||
                (tmux -f "$TMUX_CONFIG" new-session -d -s "$1" &&
                    tmux -f "$TMUX_CONFIG" "$change" -t "$1")
            return
        fi

        # otherwise, use the usual fzf script to attach to one or complaint there's no sessions
        session=$(
            tmux -f TMUX_CONFIG list-sessions -F "#{session_name}" 2>/dev/null |
                fzf --select-1 --exit-0 --height "$(tmux -f "$TMUX_CONFIG" list-sessions | wc -l)"
        ) &&
            tmux -f "$TMUX_CONFIG" "$change" -t "$session" || echo "No sessions found."
        unset TMUX_CONFIG
        unset session
    }
fi

gr() {
    is-in-git-repo || return
    local RE_FILES="^\sM\s+\K.+"
    local preview_cmd='git diff --color=always {+1} | delta'
    git restore "$(-fzf-git-restore_files)"
    unset preview_cmd
    unset RE_FILES
}

grs() {
    is-in-git-repo || return
    local RE_FILES="^M[\sMD]+\K.+"
    local preview_cmd='git diff --staged --color=always {+1} | delta'
    git restore --staged "$(-fzf-git-restore_files)"
    unset preview_cmd
    unset RE_FILES
}

fzf-git-switch-branch() {
    is-in-git-repo || return
    local target_branch
    target_branch=$(-fzf-git-choose-branch) && git switch "$target_branch"
    zle reset-prompt
    unset target_branch
}

fzf-open-file-in-editor() {
    local querystring
    [[ "$1" ]] && querystring="$1"
    preview_cmd='bat --number --color=always --paging never {+1}'
    # TODO: Figure out how to open multiple files at once in separate splits
    # Hint: paste -sd " " - will join outputs into a single line
    target_file=$(fd -t f -L -H -E .git/ | -fzf-custom-window --header "Select a file")
    test "$target_file" && "${EDITOR}" "$target_file"
    zle reset-prompt
}

fzf-cd-to-dir() {
    local querystring
    [[ "$1" ]] && querystring="$1"
    preview_cmd='exa --icons -T -L 1 --group-directories-first --git --git-ignore --colour=always {+1}'
    target_dir=$(fd --full-path "$HOME" -t d "$HOME" -L | -fzf-custom-window --header "Select a directory") &&
        test "$target_dir"
    unset querystring
    zle push-line
    cd "$target_dir" || return
    unset target_dir
    zle reset-prompt
}
