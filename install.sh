#!/bin/bash

echo 'Setting up .bashrc'
source_command='[ -f ~/.config/echoes/.echoesrc ] && . ~/.config/echoes/.echoesrc'
if ! grep -qF "$source_command" "$HOME/.bashrc"; then
  echo "$source_command" >> "$HOME/.bashrc"
fi

echo 'Copying config files'

mkdir -p "$HOME/.config/echoes"
cp .echoes_bash_prompt "$HOME/.config/echoes/.echoes_bash_prompt"
cp .git-prompt "$HOME/.config/echoes/.git-prompt"
cp .echoes_aliases "$HOME/.config/echoes/.echoes_aliases"
cp .echoesrc "$HOME/.config/echoes/.echoesrc"

echo 'Exec source ~/.bashrc or restart the terminal to see the changes'
