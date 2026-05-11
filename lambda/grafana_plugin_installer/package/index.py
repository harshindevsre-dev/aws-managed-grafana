import json
import boto3
import urllib3

grafana = boto3.client("grafana")
http = urllib3.PoolManager()


def send_response(event, context, status, data):

    response_body = {
        "Status": status,
        "Reason": "CloudFormation response",
        "PhysicalResourceId": context.log_stream_name,
        "StackId": event["StackId"],
        "RequestId": event["RequestId"],
        "LogicalResourceId": event["LogicalResourceId"],
        "Data": data
    }

    http.request(
        "PUT",
        event["ResponseURL"],
        body=json.dumps(response_body).encode("utf-8"),
        headers={"Content-Type": ""}
    )


def configure_plugins(workspace_id, plugins):

    configuration = {
        "plugins": plugins
    }

    grafana.update_workspace_configuration(
        workspaceId=workspace_id,
        configuration=json.dumps(configuration)
    )


def handler(event, context):

    try:

        print(json.dumps(event))

        request_type = event["RequestType"]

        if request_type in ["Create", "Update"]:

            properties = event["ResourceProperties"]

            workspace_id = properties["WorkspaceId"]
            plugins = properties["Plugins"]

            configure_plugins(workspace_id, plugins)

        send_response(
            event,
            context,
            "SUCCESS",
            {"Message": "Plugins configured successfully"}
        )

    except Exception as error:

        print(str(error))

        send_response(
            event,
            context,
            "FAILED",
            {"Error": str(error)}
        )
