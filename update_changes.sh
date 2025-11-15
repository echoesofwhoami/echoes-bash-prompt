rm $HOME/.bash_prompt
rm $HOME/.git-prompt
rm $HOME/.bash_aliases

cp .bash_prompt $HOME/.bash_prompt
cp .git-prompt $HOME/.git-prompt
cp .bash_aliases $HOME/.bash_aliases

echo 'Exec source ~/.bashrc or reload the configs somehow'