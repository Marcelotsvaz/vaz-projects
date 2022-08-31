# Useful Stuff


## SSH Port Forward

```sh
ssh -L 8000:localhost:8000 staging.vazprojects ssh -ttL 8000:localhost:9090 monitoring
```


## WebP Conversion

```sh
cwebp src.png -o dest.webp -lossless
cwebp src.jpg -o dest.webp -q 90 -m 6 -resize 2000 0
```