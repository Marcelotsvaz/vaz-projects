# Useful Stuff


## SSH Port Forward With Jump Host

```sh
ssh -L local:port:remote:port -J jumpHost host
ssh -L localhost:9090:localhost:9090 -J staging.vazprojects monitoring
```


## PostgreSQL Dump

```sh
docker compose exec postgres pg_dump --username postgres > database/scripts/stagingData.sql
```


## Django Dump

```sh
docker compose exec application manage.py dumpdata --all --natural-primary --natural-foreign --indent 4 auth.user taggit commonApp projectsApp blogApp > data.json
cat data.json | docker compose exec --no-TTY application manage.py loaddata --format=json -
```


## WebP Conversion

```sh
cwebp src.png -o dest.webp -lossless
cwebp src.jpg -o dest.webp -q 90 -m 6 -resize 2000 0
```