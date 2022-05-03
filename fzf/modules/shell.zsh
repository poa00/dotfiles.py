fzf-open-file-in-editor() {
    local target_file
    # TODO: Figure out how to open multiple files at once in separate splits
    # Hint: paste -sd " " - will join outputs into a single line
    target_file=$(
        fd -t f -L -H -E .git/ |
            fzf-tmux \
                --header "Select a file" \
                --preview 'bat --number --color=always --paging never {+1}'
    ) &&
        test "$target_file" &&
        "${EDITOR}" "$target_file"
    zle reset-prompt
}

fzf-choose-dir() {
    local target_dir
    target_dir=$(
        z | awk '{print $2}' |
            fzf-tmux \
                --tac \
                --header "Select a directory" \
                --preview-window=right:50% \
                --preview 'exa --icons -T -L 1 --group-directories-first --git --git-ignore --colour=always {+1}'
    ) &&
        test "$target_dir" &&
        echo "$target_dir"
}

fzf-cd-to-dir() {
    zle push-line
    cd "$(fzf-choose-dir)" || return
    zle reset-prompt

}

