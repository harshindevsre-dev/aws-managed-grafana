#!/bin/bash
set -e

echo " Deploying Grafana Dashboards..."

for file in dashboards/*.json
do
  echo "Uploading $file"

  curl -X POST "$GRAFANA_URL/api/dashboards/db" \
  -H "Authorization: Bearer $GRAFANA_API_KEY" \
  -H "Content-Type: application/json" \
  -d @grafana-alert-policy.json

done

echo " Dashboards deployed successfully"

#!/bin/bash
set -e

echo " Deploying Grafana Dashboards..."

for file in dashboards/*.json
do
  echo "Uploading $file"

  curl -X POST "$GRAFANA_URL/api/dashboards/db" \
    -H "Authorization: Bearer $GRAFANA_API_KEY" \
    -H "Content-Type: application/json" \
    -d @"$file"

done

echo " Dashboards deployed successfully"

