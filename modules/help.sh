#!/bin/bash

echoeshelp() {
    cat <<'EOF'
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
║ NETCAT LISTENERS                                             ║
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
║ UTILITIES                                                    ║
║   newmachine   [name] - setup CTF environment                ║
║   hashcrack    <file> - crack hash with rockyou              ║
║   validate_sha256 <expected> <file>                          ║
║   batdiff      [ref] - git diff with bat                     ║
║   notify       <min> <msg> - timed notification              ║
║   tofile       <file> - stdin to file                        ║
╚══════════════════════════════════════════════════════════════╝
EOF
}
