#!/bin/bash
sudo apt-get update
sudo apt-get install -y docker.io git 
curl -SL https://github.com/docker/compose/releases/download/v2.24.7/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
sudo usermod -aG docker ubuntu 
sudo chmod +x /usr/local/bin/docker-compose

git clone https://github.com/mrab72/diary.git /home/ubuntu/diary
cd /home/ubuntu/diary
nohup docker compose up -d
