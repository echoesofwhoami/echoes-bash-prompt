# 🐚 Echoes Git/Bash Prompt Setup 🐚

This repo’s for the htb folks that ask for it.

Contains a install.sh script that can be executed to install everything needed.

It contains some useful aliases for htb machines like: connectvpn, stopvpn, htbip, addhost (to /etc/hosts) etc.

Now it also shows the vpn ip when connected to a htb vpn.

The git prompt will track the current directory's git branch status and display some symbols like in this image:

![Prompt image](assets/prompt.png "Prompt image")

## Install

One-line copy-paste installer:

```bash
git clone https://github.com/echoesofwhoami/echoes-bash-prompt.git && cd echoes-bash-prompt && sh install.sh && source ~/.bashrc && cd .. && rm -rf echoes-bash-prompt
```

## FAQ
- Q: how to install?
- A: The command is just up there, RTFM is like one line.

- Q: Is it safe to run install.sh?
- A: Yes, now it is safe, just adds the prompt scripts inside $HOME/.config directory and imports it in .bashrc. Review the script before running to see exactly what it does.

- Q: How do I update it?
- A: Simply re-run the install script to get the latest version.

## Credits
Thanks to myself for making this and adding a fork of the git-prompt.
If you like it smash the respect button here https://app.hackthebox.com/users/2423666
