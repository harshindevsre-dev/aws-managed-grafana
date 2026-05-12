#!/bin/bash
set -e

echo "Deploying Grafana dashboards..."

for file in dashboards/*.json; do
  echo "Processing: $file"

  dashboard=$(jq -c '.' "$file")

  cmd="curl -s -X POST $GRAFANA_URL/api/dashboards/db \
    -H 'Authorization: Bearer $GRAFANA_API_KEY' \
    -H 'Content-Type: application/json' \
    -d '{\"dashboard\":$dashboard,\"overwrite\":true,\"folderId\":0}'"

  aws ssm send-command \
    --instance-ids "$EC2_INSTANCE_ID" \
    --document-name "AWS-RunShellScript" \
    --parameters commands="$cmd"

  echo "Done: $file"
done

echo "All dashboards deployed."
