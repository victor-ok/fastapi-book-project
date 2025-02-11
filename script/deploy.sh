#!/bin/bash

sudo apt update && sudo apt upgrade -y
echo "updating....."

export PATH=/bin:/usr/bin:$PATH

# Ensure repo exists
if [ ! -d "fastapi-book-project" ]; then
  git clone https://github.com/victor-ok/fastapi-book-project.git
  cd fastapi-book-project
  sudo ls
  echo "Install application dependencies"
  sudo python3 -m pip install --upgrade pip
  sudo pip3 install -r requirements.txt

fi

if ! command -v nginx > /dev/null; then
    echo "Installing Nginx"
    sudo apt update
    sudo apt install -y nginx
fi

if [ ! -f /etc/nginx/sites-available/app ]; then
    sudo rm -f /etc/nginx/sites-enabled/default
    sudo bash -c 'cat > /etc/nginx/sites-available/app <<EOF
    server {
    listen 80;
    server_name localhost;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF'
    sudo ln -s /etc/nginx/sites-available/app /etc/nginx/sites-enabled
    sudo systemctl restart nginx
else
    echo "Nginx reverse proxy configuration already configured"
fi

echo "pull main branch"
git pull origin main


docker-compose down
docker-compose up -d --build
sudo systemctl restart nginx
