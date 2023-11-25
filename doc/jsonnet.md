```
set -x JSONNET_PATH ../deployment/jsonnet/

cd monitoring/
jb install --jsonnetpkg-home $JSONNET_PATH
jsonnet dashboards/applicationOverview.jsonnet -o config/grafana/dashboards/applicationOverview.json
```