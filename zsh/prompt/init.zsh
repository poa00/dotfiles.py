# Powerlevel 10k config
antigen theme romkatv/powerlevel10k

POWERLEVEL9K_MODE="awesome-fontconfig"
POWERLEVEL9K_DISABLE_RPROMPT=true
POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
POWERLEVEL9K_SHORTEN_DELIMITER='..'
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir dir_writable virtualenv vcs background_jobs)

# TODO: Find a better heuristic rather than hardcode the value
if [ "$COLUMNS" -le "135" ]
then
  POWERLEVEL9K_PROMPT_ON_NEWLINE=true
  POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=""
  POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX=" %F{blue} "
fi