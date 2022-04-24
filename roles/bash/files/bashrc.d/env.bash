# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific environment

export EDITOR="nvim"

if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

[[ -x "$(command -v direnv)" ]] && eval "$(direnv hook bash)"
[[ -d $HOME/.krew ]] && export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
[[ -x "$(command -v pulumi)" ]] && export PATH="$PATH:$HOME/.pulumi/bin"
[[ -x "$(command -v scw)" ]] && eval "$(scw autocomplete script shell=bash)"

