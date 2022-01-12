# Some good standards, which are not used if the user
# creates his/her own .bashrc/.bash_profile

# --show-control-chars: help showing Korean or accented characters
alias ls='ls --color=auto --show-control-chars'
alias ll='ls -l'

# Recent versions of mintty set this variable, which R does not like
unset LC_CTYPE

# When running R inside rtools40 shell we need the corresponding toolchains
export R_CUSTOM_TOOLS_PATH="$(cygpath -m /ucrt64/bin);$(cygpath -m /usr/bin)"
export R_CUSTOM_TOOLS_SOFT="$(cygpath -m /ucrt64)"
