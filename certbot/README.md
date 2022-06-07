Simple script to auto update Let's Encypt SSL certificates

Installation
1. place the auto-update.sh in /the/path/you/like/
2. chmod 700 /the/path/you/like/auto-update.sh
3. sudo touch /var/log/certbot.log
4. sudo crontab -e

`12 23 * * * /the/path/you/like/auto-update.sh`

The above will run as (root's) crontab every day at 23:12 
That does not mean that you will get a certificate everyday as of today, Let's Encrypt skips SSL certificate creation depending on the day of your last renewal.
Trying to get a certificate everyday will ensure that you will receive it when Let's Encrypt certbot services allow you to.
