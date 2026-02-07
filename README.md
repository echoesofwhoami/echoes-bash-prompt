# Echoes Git/Bash Prompt

Contains a install.sh script that can be executed to install everything needed.

It contains some useful aliases for htb machines like: connectvpn, stopvpn, htbip, addhost (to /etc/hosts) etc.

Now it also shows the vpn ip when connected to a htb vpn.

The aliases handle everything else automatically - no need to manually manage VPN files or remember IP addresses.

## Commands

```bash
╔══════════════════════════════════════════════════════════════╗
║                     ECHOES SHELL TOOLS                       ║
╠══════════════════════════════════════════════════════════════╣
║ ALIASES                                                      ║
║   l            ls -lah                                       ║
║   ll           tree -a -L2                                   ║
║   py           python3                                       ║
║   vi           vim                                           ║
║   hosts        cat /etc/hosts                                ║
╠══════════════════════════════════════════════════════════════╣
║ NCAT CONTROLLER (non-interactive reverse-shell handler)      ║
║   nclisten     <port> - start detached ncat listener         ║
║   nccmd        "<cmd>" - send command, print output          ║
║   ncctrlstop   stop listener and clean session               ║
╠══════════════════════════════════════════════════════════════╣
║ NETCAT LOGGERS (detached netcat loggers)                     ║
║   ncstart      <port> [proto] [name] - start listener        ║
║   nclist       list active listeners                         ║
║   ncstop       <name|pid|port> - stop listener               ║
║   nclog        <name|pid|port> [lines] - view log            ║
║   ncstopall    stop all listeners                            ║
╠══════════════════════════════════════════════════════════════╣
║ VPN                                                          ║
║   connvpn      [file] - connect to VPN                       ║
║   stopvpn      stop VPN connection                           ║
║   vpns         list VPN files                                ║
║   vpnfilemv    move .ovpn from Downloads to ~/vpn            ║
║   htbip        show HTB IP                                   ║
╠══════════════════════════════════════════════════════════════╣
║ HOSTS & TARGET                                               ║
║   settargetip  <ip> - set target IP                          ║
║   targetip     show target IP                                ║
║   addhost      [ip] <domain> - add to /etc/hosts             ║
║   restorehosts reset /etc/hosts                              ║
╠══════════════════════════════════════════════════════════════╣
║ PAYLOADS                                                     ║
║   payloads     --type <TYPE> [OPTIONS]                       ║
║     Types: xss, sqli, rce, lfi, xxe, ssti                    ║
║     --tag      payload variant                               ║
║     --port     port number                                   ║
║     --listen   auto-start nc listener                        ║
║     --help     show detailed payload help                    ║
╠══════════════════════════════════════════════════════════════╣
║ TIME MANAGEMENT                                              ║
║   settime      <datetime|restore> - set time or restore NTP  ║
╠══════════════════════════════════════════════════════════════╣
║ UTILITIES                                                    ║
║   newmachine   [name] - setup CTF environment                ║
║   hashcrack    <file> - crack hash with rockyou              ║
║   validate_sha256 <expected> <file>                          ║
║   batdiff      [ref] - git diff with bat                     ║
║   notify       <min> <msg> - timed notification              ║
║   tofile       <file> - stdin to file                        ║
╚══════════════════════════════════════════════════════════════╝
```
The git prompt will track the current directory's git branch status and display some symbols like in this image:

![Prompt image](assets/prompt.png "Prompt image")

## Install/update

One-line copy-paste installer/updater:

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

- Q: I want to remove it, how do I do it?
- A: rm -rf $HOME/.config/echoes then restart the terminal

## Credits
Thanks to myself for making this and adding a fork of the git-prompt.
If you like it smash the respect button here https://app.hackthebox.com/users/2423666
Also a github star would be cool to have!
