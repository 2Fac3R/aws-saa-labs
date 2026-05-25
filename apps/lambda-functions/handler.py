import json
import boto3
import os
import time

dynamodb = boto3.resource('dynamodb')
table_name = os.environ.get('TABLE_NAME')

def lambda_handler(event, context):
    print(f"Received event: {json.dumps(event)}")
    
    # Check if we have an order in the POST body
    try:
        body = json.loads(event.get('body', '{}'))
        order_id = body.get('orderId', f"ORDER#{int(time.time())}")
        user_id = body.get('userId', 'USER#DEFAULT')
        
        table = dynamodb.Table(table_name)
        
        # SAA Topic: Write to DynamoDB
        table.put_item(
            Item={
                'PK': user_id,
                'SK': order_id,
                'Status': 'RECEIVED',
                'Total': body.get('total', '0.00'),
                'Timestamp': int(time.time())
            }
        )
        
        return {
            'statusCode': 201,
            'body': json.dumps({
                'message': 'Order processed successfully',
                'orderId': order_id,
                'userId': user_id
            })
        }
        
    except Exception as e:
        print(f"Error: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
