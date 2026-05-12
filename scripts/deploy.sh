#!/bin/bash
set -e

echo "🚀 Deploying Grafana Dashboards..."

for file in dashboards/*.json
do
  echo "📤 Uploading $file"

  # Wrap the dashboard JSON in the required Grafana API payload
  payload=$(jq -n \
    --argjson dashboard "$(cat "$file")" \
    '{dashboard: $dashboard, overwrite: true, folderId: 0}')

  curl -sf -X POST "$GRAFANA_URL/api/dashboards/db" \
    -H "Authorization: Bearer $GRAFANA_API_KEY" \
    -H "Content-Type: application/json" \
    -d "$payload"

  echo "✅ Uploaded $file"
done

echo "🎉 All dashboards deployed successfully"
