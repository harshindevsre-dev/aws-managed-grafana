#!/bin/bash
set -e

echo "🚀 Deploying Grafana Dashboards..."

# Check if dashboards directory exists
if [ ! -d "dashboards" ]; then
  echo "❌ Error: 'dashboards/' directory not found"
  echo "📁 Current directory contents:"
  ls -la
  exit 1
fi

# Check if any JSON files exist
shopt -s nullglob
json_files=(dashboards/*.json)

if [ ${#json_files[@]} -eq 0 ]; then
  echo "❌ Error: No JSON files found in dashboards/"
  echo "📁 dashboards/ contents:"
  ls -la dashboards/
  exit 1
fi

for file in "${json_files[@]}"
do
  echo "📤 Uploading $file"

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
