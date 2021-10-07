import json
import uuid


def build_response(body: object, status_code=200):
    return {
        'headers': { "Content-type": "application/json" },
        'statusCode': status_code,
        'body': json.dumps(body, indent=4)
    }


def get_job_info(event):
    job_id = event['pathParameters']['jobId']
    return build_response({'message': f'job[{job_id}] is done'})


def create_job(event):
    job_name = json.loads(event['body'])['name']
    job_id = str(uuid.uuid4())
    return build_response({'message': f'job[{job_id}] submitted'}, 201)


def handler(event, context):
    resource = event['resource']
    http_method = event['httpMethod']

    if resource == '/jobs/{jobId}' and http_method == 'GET':
        return get_job_info(event)
    elif resource == '/jobs' and http_method == 'POST':
        return create_job(event)
    else:
        return build_response({'message': 'Not found'}, 404)
