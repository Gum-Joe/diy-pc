#!/usr/bin/env bash
# Setup script for Ubuntu partition of my DIY PC
export ATOM_URL="https://github.com/atom/atom/releases/download/v1.9.9/atom-amd64.deb"
export ATOM_SAVE="atom-amd64.deb"
export CHROME_URL="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
export CHROME_SAVE="google-chrome-stable_current_amd64.deb"
export PACKAGES="git wget default-jre default-jdk mongodb-org maven vlc browser-plugin-vlc virtualbox vagrant"
export NPM_PACKAGES="mocha coffee-script gulp grunt-cli istanbul nodemon"
export RUBY_GEMS="bundler sass compass"
export START_DIR="$PWD"
export APT_ARGS=""

# Check if --auto was passed
if [[ "$@" == *"--auto"* ]]
then
  export APT_ARGS="-y"
fi

# Function to check exit code of a program
check_exit() {
  echo ""
  echo "A command returned a non-zero exit code!"
  echo "Exiting."
  exit 1
}

echo "---> Installing packages"
# Step 1: Add sources
echo "---> Updating package database + installing packages to help with sources..."
sudo apt-get update || check_exit
sudo apt install apt-transport-https ca-certificates $APT_ARGS || check_exit
echo ""
echo "---> Adding package sources..."
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 || check_exit
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D || check_exit
echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list || check_exit
echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" | sudo tee /etc/apt/sources.list.d/docker.list || check_exit

# Step 2: Run apt-get update & upgrade
echo ""
echo "---> Updating package database + updating current packages..."
sudo apt-get update || check_exit
sudo apt-get upgrade $APT_ARGS || check_exit

# Step 3: Install apt packages
echo ""
echo "---> Installing packages we want..."
echo "     Packages: $PACKAGES"
sudo apt install $PACKAGES $APT_ARGS || check_exit

# Install packages from sources not registered with apt-get
echo ""
echo "---> Installing packages from external sources"
echo "---> All packages are saved to ~/.setup-cache"
mkdir ~/.setup-cache
cd ~/.setup-cache
# Install atom
echo "---> Downloading GitHub's Atom text editor ($ATOM_URL) and saving to $ATOM_SAVE"
wget -O $ATOM_SAVE $ATOM_URL
echo ""
echo "---> Installing GitHub's Atom text editor..."
sudo dpkg -i $ATOM_SAVE
# Install google chrome
echo ""
echo "---> Downloading Google Chrome ($ATOM_URL) and saving to $CHROME_SAVE"
wget -O $CHROME_SAVE $CHROME_URL
echo ""
echo "---> Installing Google Chrome..."
sudo dpkg -i $CHROME_SAVE

# Step 4: Install docker
echo ""
echo "---> Installing docker..."
echo "---> Updating kernal..."
sudo apt install linux-image-extra-$(uname -r) linux-image-extra-virtual $APT_ARGS || check_exit
echo ""
echo "---> Installing docker..."
sudo apt install docker-engine $APT_ARGS || check_exit
echo ""
echo "---> Creating docker user group and adding this user ($USER) to it..."
sudo groupadd docker || check_exit
sudo usermod -aG docker $USER || check_exit

# Step 4: Install nvm for nodejs
echo ""
echo "---> Installing nvm for nodejs..."
# Script may need updating
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.4/install.sh | bash || check_exit
echo ""
echo "---> Reloading ~/.bashrc"
. ~/.bashrc || check_exit
echo ""
echo "---> Installing nodejs (stable)..."
nvm install stable || check_exit
echo ""
echo "---> Installing global npm packages..."
echo "     Packages: $NPM_PACKAGES"
npm install -g $NPM_PACKAGES || check_exit

# Step 5: Install rvm for ruby
echo ""
echo "---> Install rvm for ruby..."
echo "---> Adding rvm key"
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 || check_exit
echo ""
echo "---> Installing rvm..."
curl -sSL https://get.rvm.io | bash -s stable || check_exit
echo ""
echo "---> Reloading ~/.bashrc"
. ~/.bashrc || check_exit
echo ""
echo "---> Install ruby (ruby-head) & using it"
rvm install ruby-head --binary || check_exit
rvm use ruby-head || check_exit
echo ""
echo "---> Installing ruby gems..."
echo "     Gems: $RUBY_GEMS"
gem install $RUBY_GEMS || check_exit

# Step 6: Installing virtualenv for python
echo ""
echo "---> Installing virtualenv for python..."
sudo pip install virtualenv || check_exit

# Step 7: Start services
echo ""
echo "---> Starting services..."
echo "---> Starting docker..."
sudo service docker start || check_exit
echo ""
echo "---> Starting mongodb..."
sudo service mongod start || check_exit

# Restart computer
echo ""
echo "ATTENTION! ATTENTION! ATTENTION! ATTENTION!"
echo "    Your computer is about to restart.     "
echo "ATTENTION! ATTENTION! ATTENTION! ATTENTION!"
echo ""
if [[ "$@" != *"--auto"* ]]
then
  read -p "Reboot now? [Y/n] " REBOOT;
  if [ "$REBOOT" == "n" ] || [ "$REBOOT" == "N" ]; then
    exit 0
  fi
fi
sudo reboot

# Script by Gum-Joe
