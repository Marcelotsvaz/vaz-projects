# Useful Stuff


## SSH Port Forward With Jump Host

```sh
ssh -L local:port:remote:port -J jumpHost host
ssh -L localhost:9090:localhost:9090 -J staging.vazprojects monitoring
```


## WebP Conversion

```sh
cwebp src.png -o dest.webp -lossless
cwebp src.jpg -o dest.webp -q 90 -m 6 -resize 2000 0
```