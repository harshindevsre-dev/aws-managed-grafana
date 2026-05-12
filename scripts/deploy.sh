name: Deploy Grafana Dashboards

on:
  push:
    branches:
      - main
    paths:
      - "dashboards/**"
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repo
        uses: actions/checkout@v4

      - name: Install dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y jq awscli

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ secrets.AWS_REGION }}

      - name: Make deploy script executable
        run: chmod +x deploy.sh

      - name: Deploy Grafana dashboards via SSM
        env:
          EC2_INSTANCE_ID: ${{ secrets.EC2_INSTANCE_ID }}
          GRAFANA_API_KEY: ${{ secrets.GRAFANA_API_KEY }}
        run: ./deploy.sh
