# share history with other shells
setopt share_history
# deduplicate history
setopt histignorealldups
# Write to the history file immediately, not when the shell exits.
setopt inc_append_history
# history
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# disable lock by ctrl + s , ctrl + q
setopt no_flow_control

# chdir without cd
setopt auto_cd
# correct commands
setopt correct
# カッコの対応などを自動的に補完する
setopt auto_param_keys
# No Beep
setopt no_beep
setopt no_list_beep
setopt no_hist_beep

