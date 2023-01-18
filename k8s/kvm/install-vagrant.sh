# https://developer.hashicorp.com/vagrant/downloads
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vagrant

# install vagrant-libvtr 
sudo apt install libvirt-dev
sudo apt install build-essential
# sudo vagrant plugin install pkg-config
sudo vagrant plugin install vagrant-libvirt

export VAGRANT_DEFAULT_PROVIDER=libvirt