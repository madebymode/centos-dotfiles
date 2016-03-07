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

e_header "detecting if you're running 32 or 64-bit"

MACHINE_TYPE="$(uname -m)"
if [ ${MACHINE_TYPE} == 'x86_64' ]; then
  # 64-bit stuff here
  dist="x86_64"
  rpm_dist="x86_64"
  echo "64 yeah boi"
else
  # 32-bit stuff here
  dist="i686"
  rpm_dist="i386"
  echo "32-biter"
fi

e_header "Installing Additional RPMs (Epel and iUS)"

sudo rpm -Uvh http://dl.iuscommunity.org/pub/ius/stable/Redhat/6/${rpm_dist}/epel-release-6-5.noarch.rpm
sudo rpm -Uvh http://dl.iuscommunity.org/pub/ius/stable/Redhat/6/${rpm_dist}/ius-release-1.0-11.ius.el6.noarch.rpm

sudo yum update -y -q

#remove old mysql libs if needed
if [ ! "$(rpm -qa | grep -P "mysql5.*u.*\.${dist}")" ]; then
  e_header "removing mysql-libs from base image"
  sudo yum remove mysql-libs -y
fi

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
  php56u-fpm
  htop
  tree
  nginx
  yum-plugin-replace
  openssl-devel
  readline-devel
  zlib-devel
  vim
)

if (( ${#packages[@]} > 0 )); then
  e_header "Installing YUM packages: ${packages[*]}"
  for package in "${packages[@]}"; do
    sudo yum -q -y install "$package"
  done
fi

#update git
if [ ! "$(rpm -qa | grep -P "git2u.*\.centos6\.${dist}")" ]; then
  e_header "Updating Git to v2.7"
  sudo yum replace git --replace-with=git2u -y -q
fi
# Install Git Extras
if [[ ! "$(type -P git-extras)" ]]; then
  e_header "Installing Git Extras"
  (
    cd $DOTFILES/vendor/git-extras &&
    sudo make install
  )
fi
#Phusion Passenger
sudo yum install -y epel-release pygpgme curl
# Add their el6 YUM repository
sudo curl --fail -sSLo /etc/yum.repos.d/passenger.repo https://oss-binaries.phusionpassenger.com/yum/definitions/el-passenger.repo
# Install Passenger + Apache module
sudo yum install -y mod_passenger
# Install Passenger + Nginx
sudo yum install -y nginx passenger
