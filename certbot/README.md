Simple Ubuntu script to auto update Let's Encypt SSL certificates

Warning: this script assumes that you don't use port 80 at all for your web server. 

Installation
1. place the `auto-update.sh` in `/the/path/you/like/`
2. `chmod 700 /the/path/you/like/auto-update.sh`
3. `sudo touch /var/log/certbot.log`
4. `sudo crontab -e`

`12 23 * * * /the/path/you/like/auto-update.sh`

The above will run as (root's) crontab every day at 23:12 and will execute the following :
1. `ufw` opens port 80
2. executes `certbot` renew process
3. `ufw` closes port 80

The above will keep a log at `/var/log/certbot.log` and you should check the output.

That does not mean that you will get a certificate everyday as Let's Encrypt policies skip certificate creation depending on the day of your last renewal.

Trying to get a certificate everyday will ensure that you will receive it when Let's Encrypt certbot services allow you to.
