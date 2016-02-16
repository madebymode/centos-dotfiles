# CentOS-only stuff. Abort if not CentOS.
is_centos || return 1

# Package management
alias update="sudo yum update"
alias install="sudo yum install"
alias uninstall="sudo yum remove"
alias remove="sudo yum remove"
alias search="yum search"

# Make 'less' more.
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Switch between already-downloaded node versions.
function node_ver() {
  (
    ver="${1#v}"
    nodes=()
    if [[ ! -e "/usr/local/src/node-v$ver" ]]; then
      shopt -s extglob
      shopt -s nullglob
      cd "/usr/local/src"
      eval 'for n in node-v*+([0-9]).+([0-9]).+([0-9]); do nodes=("${nodes[@]}" "${n#node-}"); done'
      [[ "$1" ]] && echo "Node.js version \"$1\" not found."
      echo "Valid versions are: ${nodes[*]}"
      [[ "$(type -P node)" ]] && echo "Current version is: $(node --version)"
      exit 1
    fi
    cd "/usr/local/src/node-v$ver"
    sudo make install >/dev/null 2>&1 &&
    echo "Node.js $(node --version) installed." ||
    echo "Error, $(node --version) installed."
  )
}
