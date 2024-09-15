sudo fallocate -l 8G /mnt/8GB.swap
sudo chmod 0600 /mnt/8GB.swap
sudo mkswap /mnt/8GB.swap
sudo echo '/mnt/8GB.swap  none  swap  sw 0  0' | sudo tee -a /etc/fstab