output "public_ip_ec2" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.devops_ec2.public_ip
}


sudo apt update -y
sudo apt upgrade -y


sudo apt remove docker docker-engine docker.io containerd runc -y

sudo apt install -y ca-certificates curl gnupg lsb-release


sudo mkdir -p /etc/apt/keyrings
curl -fsSL https:
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg


echo 
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null


sudo apt update -y


sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo systemctl enable docker
sudo systemctl start docker

sudo usermod -aG docker $USER


docker --version

echo "docker successfully installed."
