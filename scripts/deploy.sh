#!/bin/bash
set -euo pipefail

echo "🚀 Deploying Grafana Dashboards via SSM..."

: "${EC2_INSTANCE_ID:?EC2_INSTANCE_ID not set}"
: "${GRAFANA_API_KEY:?GRAFANA_API_KEY not set}"

for file in dashboards/*.json
do
  echo "📤 Processing $file"

  payload=$(jq -c \
    --argjson dashboard "$(cat "$file")" \
    '{dashboard: $dashboard, overwrite: true, folderId: 0}')

  COMMAND_ID=$(aws ssm send-command \
    --instance-ids "$EC2_INSTANCE_ID" \
    --document-name "AWS-RunShellScript" \
    --parameters commands="[
      \"curl -sf -X POST http://localhost:3000/api/dashboards/db \
        -H 'Authorization: Bearer $GRAFANA_API_KEY' \
        -H 'Content-Type: application/json' \
        -d '$payload'\"
    ]" \
    --query 'Command.CommandId' \
    --output text)

  echo "⏳ Command ID: $COMMAND_ID"

  aws ssm wait command-executed \
    --command-id "$COMMAND_ID" \
    --instance-id "$EC2_INSTANCE_ID"

  aws ssm get-command-invocation \
    --command-id "$COMMAND_ID" \
    --instance-id "$EC2_INSTANCE_ID" \
    --query '[Status,StandardOutputContent,StandardErrorContent]' \
    --output text

  echo "✅ Done: $file"
done

echo "🎉 Deployment completed"
