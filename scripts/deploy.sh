#!/bin/bash
set -euo pipefail

echo "Starting Grafana dashboard deployment via SSM..."

: "${EC2_INSTANCE_ID:?EC2_INSTANCE_ID is required}"
: "${GRAFANA_API_KEY:?GRAFANA_API_KEY is required}"

for file in dashboards/*.json; do
  echo "Uploading dashboard: $file"

  dashboard_payload=$(jq -c \
    --argjson dashboard "$(cat "$file")" \
    '{dashboard: $dashboard, overwrite: true, folderId: 0}')

  command_id=$(aws ssm send-command \
    --instance-ids "$EC2_INSTANCE_ID" \
    --document-name "AWS-RunShellScript" \
    --parameters commands="[
      \"curl -s -X POST http://localhost:3000/api/dashboards/db \
        -H 'Authorization: Bearer $GRAFANA_API_KEY' \
        -H 'Content-Type: application/json' \
        -d '$dashboard_payload'\"
    ]" \
    --query 'Command.CommandId' \
    --output text)

  echo "Command sent: $command_id"

  aws ssm wait command-executed \
    --command-id "$command_id" \
    --instance-id "$EC2_INSTANCE_ID"

  aws ssm get-command-invocation \
    --command-id "$command_id" \
    --instance-id "$EC2_INSTANCE_ID" \
    --query '[Status,StandardOutputContent,StandardErrorContent]' \
    --output text

  echo "Completed: $file"
done

echo "Dashboard deployment finished."
