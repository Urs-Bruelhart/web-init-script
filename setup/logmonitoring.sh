echo "Installing and configuring logwatch for log monitoring"
# https://help.ubuntu.com/community/Logwatch
echo "--------------------------------------------------------------"
#
aptitude -y install logwatch
mkdir /var/cache/logwatch
cp /usr/share/logwatch/default.conf/logwatch.conf /etc/logwatch/conf/
#
sed -i "s/MailTo = root/MailTo = $ADMINEMAIL/g" /etc/logwatch/conf/logwatch.conf
sed -i "s/Detail = Low/Detail = High/g" /etc/logwatch/conf/logwatch.conf
sed -i "s/Format = text/Format = html/g" /etc/logwatch/conf/logwatch.conf
#
cp /usr/share/logwatch/default.conf/logfiles/http.conf to /etc/logwatch/conf/logfiles
#
echo "
# Log files for $DOMAIN
LogFile = /home/$USER/public_html/$DOMAIN/log/access.log
LogFile = /home/$USER/public_html/$DOMAIN/log/error.log
LogFile = /home/$USER/public_html/$DOMAIN/log/ssl_error.log
LogFile = /home/$USER/public_html/$DOMAIN/log/ssl_access.log
" >> /etc/logwatch/conf/logfiles/http.conf
