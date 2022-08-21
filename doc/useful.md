# Useful Stuff


## SSH Port Forward

```sh
ssh -L 8000:localhost:8000 staging.vazprojects ssh -ttL 8000:localhost:9090 monitoring
```