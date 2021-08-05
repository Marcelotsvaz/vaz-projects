ssh venditore 'tail -n +1 -f ~django/logs/nginx-access.log' | goaccess --log-format=COMBINED -a -
ssh venditore 'tail -n +1 -f ~django/logs/nginx-access.log' | goaccess --log-format=COMBINED -o test.html --real-time-html -
ssh venditore 'tail -n +1 -f ~django/logs/nginx-access.log' | goaccess --log-format=COMBINED -o test.html --real-time-html --geoip-database=/usr/share/GeoIP/GeoLite2-City.mmdb