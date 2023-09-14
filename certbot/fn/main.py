import boto3
import os
from acme import client
from acme import messages
from acme import challenges

BUCKET_NAME    = os.environ['S3_BUCKET_NAME']
OBJECT_KEY     = os.environ['S3_OBJECT_KEY']
ZONE_ID = os.environ['ZONE_ID']
DOMAIN_NAME    = os.environ['DOMAIN_NAME']
ACME_KEY       = os.environ['ACME_KEY']

def handler(event, context):
    
    # Initialize ACME client
    directory_url = 'https://acme-v02.api.letsencrypt.org/directory'
    acme_client = client.ClientV2(
        directory_url,
        client.ClientNetwork(ACME_KEY)
    )

    # Register account
    regr = acme_client.new_account(
        messages.NewRegistration.from_data(
            email="your_email@example.com",
            terms_of_service_agreed=True
        )
    )

    # Start DNS-01 challenge
    order = acme_client.new_order([DOMAIN_NAME])
    challenge = [
        c for c in order.authorizations[0].body.challenges
        if isinstance(c.chall, challenges.DNS01)
    ][0]

    # Get the challenge details
    challenge_validation = challenges.DNS01(ACME_KEY).validation(DOMAIN_NAME)
    challenge_domain = challenges.DNS01(ACME_KEY).validation_domain_name(DOMAIN_NAME)

    # Update Route53 DNS records
    route53 = boto3.client('route53')
    route53.change_resource_record_sets(
        HostedZoneId=ZONE_ID,
        ChangeBatch={
            'Changes': [{
                'Action': 'UPSERT',
                'ResourceRecordSet': {
                    'Name': challenge_domain,
                    'Type': 'TXT',
                    'TTL': 60,
                    'ResourceRecords': [
                        {'Value': f'"{challenge_validation}"'}
                    ]
                }
            }]
        }
    )

    # Notify ACME server that challenge is complete
    acme_client.answer_challenge(
        challenge,
        challenge.response(ACME_KEY)
    )

    # Obtain the certificate
    order = acme_client.poll_and_finalize(order)

    # Save the certificate to S3
    s3 = boto3.client('s3')
    s3.put_object(
        Bucket=BUCKET_NAME,
        Key=OBJECT_KEY,
        Body=order.fullchain_pem.encode()
    )

    return {
        'statusCode': 200,
        'body': 'Certificate obtained and saved to S3!'
    }
