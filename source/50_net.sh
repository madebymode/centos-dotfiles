# IP addresses
alias wanip="dig +short myip.opendns.com @resolver1.opendns.com"
alias whois="whois -h whois-servers.net"

# Flush Directory Service cache
alias flush="sudo /etc/init.d/bind restart"

# View HTTP traffic
alias httpdump="sudo tcpdump -i en1 -n -s 0 -w - | grep -a -o -E \"Host\: .*|GET \/.*\""

# Show all the names (CNs and SANs) listed in the SSL certificate
# for a given domain
function getcertnames() {
  if [ -z "${1}" ]; then
    echo "ERROR: No domain specified.";
    return 1;
  fi;

  local domain="${1}";
  echo "Testing ${domain}…";
  echo ""; # newline

  local tmp=$(echo -e "GET / HTTP/1.0\nEOT" \
    | openssl s_client -connect "${domain}:443" -servername "${domain}" 2>&1);

  if [[ "${tmp}" = *"-----BEGIN CERTIFICATE-----"* ]]; then
    local certText=$(echo "${tmp}" \
      | openssl x509 -text -certopt "no_aux, no_header, no_issuer, no_pubkey, \
      no_serial, no_sigdump, no_signame, no_validity, no_version");
    echo "Common Name:";
    echo ""; # newline
    echo "${certText}" | grep "Subject:" | sed -e "s/^.*CN=//" | sed -e "s/\/emailAddress=.*//";
    echo ""; # newline
    echo "Subject Alternative Name(s):";
    echo ""; # newline
    echo "${certText}" | grep -A 1 "Subject Alternative Name:" \
      | sed -e "2s/DNS://g" -e "s/ //g" | tr "," "\n" | tail -n +2;
    return 0;
  else
    echo "ERROR: Certificate not found.";
    return 1;
  fi;
}

# SSH Keys
function keyme () {
  if [ -z "$1" -o -z "$2" ]; then
    echo "Please provide your email and a name for the key (preferably the server domain) - usage: newkey <email> <keyname>"
    return 1
  fi
  ssh-keygen -t rsa -b 4096 -C "$1" -f "$HOME/.ssh/${2}_rsa"

  read -r -p "Would you like to upload this key to a server now? [y/N] " response
  response=${response}    # tolower
  if [[ $response =~ ^(yes|y)$ ]]; then
    echo -n "Enter the server hostname or IP address and press [ENTER]: "
    read server
    echo -n "Enter your username for $server and press [ENTER]: "
    read username
    ssh-copy-id -i "$HOME/.ssh/${2}_rsa.pub" "$username@$server"
  fi
}

function getkey2 () {
  if [ -z "$1" ]; then
    echo "Please provide a keyname (it's probably the domain) - usage: getkey2 <keyname>"
    return 1
  fi
  local keyname="$1"

  if [ -z "$keyname" ]; then
    keyname="id"
  fi

  echo "Public key from file $HOME/.ssh/${keyname}_rsa.pub" && echo ""
  cat "$HOME/.ssh/${keyname}_rsa.pub"
}
