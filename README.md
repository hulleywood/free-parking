# Free Parking For Me

Displays a map showing temporary parking permits and associated information in San Francisco, CA. To use: move map to where you are, and start calling!

Cron to run on server:

```
0 0 * * * /bin/bash -l -c 'cd /home/rails/free-parking; RAILS_ENV=production rake permits:remove_old permits:create_new permits:create_json signs:remove_old signs:create_new signs:create_json' >> /var/log/cron.log 2>&1
```
