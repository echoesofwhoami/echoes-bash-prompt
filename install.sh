#!/bin/bash

add_to_bashrc() {
  local new_content="$1"
  local file_path="$HOME/.bashrc"
  if ! grep -qF "$new_content" "$file_path"; then
    echo -e "$new_content" >> "$file_path"
  fi
}

echo 'Setting up .bashrc'

add_to_bashrc "source $HOME/.bash_prompt \n"
add_to_bashrc "source $HOME/.git-prompt \n"
add_to_bashrc "LS_COLORS=\$LS_COLORS:'di=38;5;160:'; export LS_COLORS \n"
add_to_bashrc "[ -f ~/.bash_aliases ] && . ~/.bash_aliases \n"

echo 'Copying bash config files'

cp .bash_prompt $HOME/.bash_prompt
cp .git-prompt $HOME/.git-prompt
cp .bash_aliases $HOME/.bash_aliases

echo 'Exec source ~/.bashrc or reload the configs somehow'
