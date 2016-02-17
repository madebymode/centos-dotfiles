# CentOS-only stuff. Abort if not CentOS.
is_centos || return 1

# If the old files isn't removed, the duplicate YUM alias will break sudo!
sudoers_old="/etc/sudoers.d/sudoers-mode"; [[ -e "$sudoers_old" ]] && sudo rm "$sudoers_old"

# Installing this sudoers file makes life easier.
sudoers_file="sudoers-dotfiles"
sudoers_src=$DOTFILES/conf/centos/$sudoers_file
sudoers_dest="/etc/sudoers.d/$sudoers_file"
if [[ ! -e "$sudoers_dest" || "$sudoers_dest" -ot "$sudoers_src" ]]; then
  cat <<EOF
The sudoers file can be updated to allow "sudo yum" to be executed
without asking for a password. You can verify that this worked correctly by
running "sudo yum". If it doesn't ask for a password, and the output
looks normal, it worked.

THIS SHOULD ONLY BE ATTEMPTED IF YOU ARE LOGGED IN AS ROOT IN ANOTHER SHELL.

This will be skipped if "Y" isn't pressed within the next $prompt_delay seconds.
EOF
  read -N 1 -t $prompt_delay -p "Update sudoers file? [y/N] " update_sudoers; echo
  if [[ "$update_sudoers" =~ [Yy] ]]; then
    e_header "Updating sudoers"
    visudo -cf "$sudoers_src" &&
    sudo cp "$sudoers_src" "$sudoers_dest" &&
    sudo chmod 0440 "$sudoers_dest" &&
    echo "File $sudoers_dest updated." ||
    echo "Error updating $sudoers_dest file."
  else
    echo "Skipping."
  fi
fi

# Update YUM
e_header "Updating YUM"
sudo yum update -y -q

e_header "Installing Additional RPMs (Epel and iUS)"
sudo rpm -Uvh http://dl.iuscommunity.org/pub/ius/stable/Redhat/6/x86_64/epel-release-6-5.noarch.rpm
sudo rpm -Uvh http://dl.iuscommunity.org/pub/ius/stable/Redhat/6/x86_64/ius-release-1.0-11.ius.el6.noarch.rpm

sudo yum update -y -q

# Install YUM packages.
packages=(
  httpd
  mysql56u-server
  php56u
  php56u-mysql
  php56u-gd
  php56u-mcrypt
  php56u-devel
  php56u-mbstring
  httpd-devel
  gcc
  php56u-pear
  htop
  tree
  yum-plugin-replace
)

if (( ${#packages[@]} > 0 )); then
  e_header "Installing YUM packages: ${packages[*]}"
  for package in "${packages[@]}"; do
    sudo yum -q -y install "$package"
  done
fi

#update git-extras
e_header "Updating Git to v2.7"
sudo yum replace git --replace-with=git2u -y -q

# Install Git Extras
if [[ ! "$(type -P git-extras)" ]]; then
  e_header "Installing Git Extras"
  (
    cd $DOTFILES/vendor/git-extras &&
    sudo make install
  )
fi
