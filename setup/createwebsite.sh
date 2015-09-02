#!/bin/bash
# ================================================================== #
# Shell script to add a website on nginx.
# ================================================================== #
# Copyright (c) 2012 Matt Thomas http://betweenbrain.com
# This script is licensed under GNU GPL version 2.0 or above
# ================================================================== #
#

# Script to add a user and website to the Linux system
read -s -p "Enter your website formatted as example.com: " WEBSITE

# add the website as user and group
sudo groupadd $WEBSITE
sudo useradd -g $WEBSITE $WEBSITE

# Create php-fpm pool 
FILE="/etc/php5/fpm/pool.d/$WEBSITE.conf"

/bin/cat <<EOM >$FILE
[$WEBSITE]
user = $WEBSITE
group = $WEBSITE
listen = /var/run/php5-fpm-$WEBSITE.sock
listen.owner = www-data
listen.group = www-data
php_admin_value[disable_functions] = exec,passthru,shell_exec,system
php_admin_flag[allow_url_fopen] = off
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
chdir = /
EOM

# print out what you have done
echo "Done creating database $WEBSITE"

# change opcache settings
FILE2="/etc/php5/fpm/conf.d/05-opcache.ini"
/bin/cat <<EOM >> $FILE2
opcache.enable=0
EOM

# restart php-fpm for the new settings to take effect 
sudo service php5-fpm restart

# print out what you have done
echo "Done restart php-fpm"

# add nginx configuration for the website
FILE3="/etc/nginx/sites-available/$WEBSITE"

/bin/cat <<EOM > $FILE3
server {
    listen 80;

    root /usr/share/nginx/sites/$WEBSITE;
    index index.php index.html index.htm;

    server_name $WEBSITE;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/php5-fpm-$WEBSITE.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
EOM

# Create the web root directory:
sudo mkdir /var/www/
sudo mkdir /var/www/$WEBSITE

# change opcache settings
FILE4="/var/www/$WEBSITE/index.html"
/bin/cat <<EOM > $FILE4
<!doctype html>
<html lang="nl">
<head>
  <meta charset="utf-8">
  <title>harmonic-society.com</title>
  <style>
    ::-moz-selection { background: #fe57a1; color: #fff; text-shadow: none; }
    ::selection { background: #fe57a1; color: #fff; text-shadow: none; }
    html { padding: 30px 10px; font-size: 20px; line-height: 1.4; color: #737373; background: #f0f0f0; -webkit-text-size-adjust: 100%; -ms-text-size-adjust: 100%; }
    html, input { font-family: "Helvetica Neue", Helvetica, Arial, sans-serif; }
    body { max-width: 500px; _width: 500px; padding: 30px 20px 50px; border: 1px solid #b3b3b3; border-radius: 4px; margin: 0 auto; box-shadow: 0 1px 10px #a7a7a7, inset 0 1px 0 #fff; background: #fcfcfc; }
    h1 { margin: 0 10px; font-size: 35px; text-align: center; }
    p { margin: 1em 0; }
    .container { max-width: 400px; _width: 380px; margin: 0 auto; }
  </style>
</head>
<body>
  <div class="container">
    <h1>This is $WEBSITE.com</h1>
  </div>
</body>
</html>
EOM
echo "created directory for /var/www/$WEBSITE"


# enable the site 
sudo ln -s /etc/nginx/sites-available/$WEBSITE /etc/nginx/sites-enabled/$WEBSITE

# restart the nginx to take the new website into effect
sudo service nginx restart
echo "$WEBSITE is ready to use"