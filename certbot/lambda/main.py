import subprocess
import boto3
import os

BUCKET_NAME = os.environ['BUCKET_NAME']
DOMAIN_NAME = os.environ['DOMAIN_NAME']

def handler(event, context):
    # Run certbot to obtain the certificate using DNS-01 challenge with Route53
    cmd = [
        'certbot', 'certonly', '--non-interactive', '--agree-tos',
        '-m', 'nicholasbudzban@gmail.com',
        '--dns-route53',
        '-d', DOMAIN_NAME,
        '--config-dir', '/tmp/config',
        '--work-dir', '/tmp/work',
        '--logs-dir', '/tmp/logs'
    ]
    subprocess.check_call(cmd)

    # Upload the obtained certificate to S3
    s3 = boto3.client('s3')
    with open('/tmp/config/live/{}/fullchain.pem'.format(DOMAIN_NAME), 'w') as cert_file:
        s3.upload_fileobj(cert_file, BUCKET_NAME, 'fullchain.pem')
    with open('/tmp/config/live/{}/privkey.pem'.format(DOMAIN_NAME), 'w') as key_file:
        s3.upload_fileobj(key_file, BUCKET_NAME, 'privkey.pem')

    return {
        'statusCode': 200,
        'body': 'Certificate obtained and saved to S3!'
    }
