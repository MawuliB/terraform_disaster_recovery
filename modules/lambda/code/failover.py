import boto3
import os
import time

# Use the secondary region for operations
secondary_region = os.environ['SECONDARY_REGION']
ec2 = boto3.client('ec2', region_name=secondary_region)
autoscaling = boto3.client('autoscaling', region_name=secondary_region)
rds = boto3.client('rds', region_name=secondary_region)
route53 = boto3.client('route53')
sns = boto3.client('sns')

def handler(event, context):
    # Notify the admin that a failover is starting
    sns_topic_arn = os.environ['SNS_TOPIC_ARN']
    sns.publish(TopicArn=sns_topic_arn, Message="Failover initiated. Starting failover process...")

    # ---- Step 1: Start the standby instance ----
    instance_id = os.environ['STANDBY_INSTANCE_ID']
    print(f"Starting standby instance: {instance_id}")
    ec2.start_instances(InstanceIds=[instance_id])
    
    # Wait for the instance to transition to 'running'
    ec2.get_waiter('instance_running').wait(InstanceIds=[instance_id])
    
    # ---- Step 2: Retrieve the public IP of the standby instance ----
    response = ec2.describe_instances(InstanceIds=[instance_id])
    instance = response['Reservations'][0]['Instances'][0]
    public_ip = instance.get('PublicIpAddress')
    print(f"Standby instance public IP: {public_ip}")
    
    # ---- Step 3: Update Route 53 to point to the standby instance ----
    hosted_zone_id = os.environ['HOSTED_ZONE_ID']
    domain_name = os.environ['DOMAIN_NAME']
    change_batch_instance = {
        'Comment': 'Failover: Route traffic to standby instance',
        'Changes': [{
            'Action': 'UPSERT',
            'ResourceRecordSet': {
                'Name': domain_name,
                'Type': 'A',
                'TTL': 60,
                'ResourceRecords': [{'Value': public_ip}]
            }
        }]
    }
    print("Updating Route 53 record to point to the standby instance...")
    route53.change_resource_record_sets(
        HostedZoneId=hosted_zone_id,
        ChangeBatch=change_batch_instance
    )
    print("Route 53 updated to standby instance.")
    
    # ---- Step 4: Update the ASG configuration in the DR region ----
    asg_name = os.environ['ASG_NAME']
    print(f"Updating ASG {asg_name} to desired capacity 1, min 1, max 2...")
    autoscaling.update_auto_scaling_group(
         AutoScalingGroupName=asg_name,
         MinSize=1,
         DesiredCapacity=1,
         MaxSize=2
    )
    
    # Wait for the ASG instances to become healthy.
    print("Waiting 5 minutes for ASG instances to launch and become healthy...")
    time.sleep(300)  # Wait 5 minutes
    
    # ---- Step 5: Update Route 53 to point to the ELB behind the ASG ----
    elb_dns = os.environ['ELB_DNS']
    elb_hosted_zone_id = os.environ['ELB_HOSTED_ZONE_ID']
    change_batch_elb = {
        'Comment': 'Failover complete: Route traffic to ELB behind ASG',
        'Changes': [{
            'Action': 'UPSERT',
            'ResourceRecordSet': {
                'Name': domain_name,
                'Type': 'A',
                'AliasTarget': {
                    'HostedZoneId': elb_hosted_zone_id,
                    'DNSName': elb_dns,
                    'EvaluateTargetHealth': False
                }
            }
        }]
    }
    print("Updating Route 53 record to point to the ELB...")
    route53.change_resource_record_sets(
        HostedZoneId=hosted_zone_id,
        ChangeBatch=change_batch_elb
    )
    print("Route 53 updated to point to the ELB.")

    # ---- Step 6: Promote the RDS Read Replica to Primary ----
    read_replica_id = os.environ['READ_REPLICA_ID']
    print(f"Promoting RDS read replica {read_replica_id}...")
    promotion_response = rds.promote_read_replica(DBInstanceIdentifier=read_replica_id)
    print("Promotion initiated:", promotion_response)
    
    # Wait for the DB instance to be available after promotion
    print("Waiting for the promoted DB instance to become available...")
    rds.get_waiter('db_instance_available').wait(DBInstanceIdentifier=read_replica_id)
    
    # Retrieve the DB endpoint (the new DB URL)
    db_info = rds.describe_db_instances(DBInstanceIdentifier=read_replica_id)
    db_endpoint = db_info['DBInstances'][0]['Endpoint']['Address']
    print("Promoted DB endpoint (URL):", db_endpoint)

    # Notify the admin that the failover is complete
    sns.publish(TopicArn=sns_topic_arn, Message="Failover complete. Failover process is complete.")
    
    return {"status": "Failover complete", "db_endpoint": db_endpoint}
