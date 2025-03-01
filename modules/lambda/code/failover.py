import boto3
import os
import time

# Use the secondary region for operations
secondary_region = os.environ['SECONDARY_REGION']
primary_region = os.environ['PRIMARY_REGION']

ec2 = boto3.client('ec2', region_name=secondary_region)
autoscaling = boto3.client('autoscaling', region_name=secondary_region)
rds = boto3.client('rds', region_name=secondary_region)
sns = boto3.client('sns', region_name=primary_region)

def handler(event, context):
    # Notify admin that failover is starting
    sns_topic_arn = os.environ['SNS_TOPIC_ARN']
    sns.publish(TopicArn=sns_topic_arn, Message="Failover initiated. Starting failover process...")

    # ---- Step 1: Update the ASG configuration in the DR region ----
    asg_name = os.environ['ASG_NAME']
    print(f"Updating ASG {asg_name} to desired capacity 1, min 1, max 2...")
    autoscaling.update_auto_scaling_group(
         AutoScalingGroupName=asg_name,
         MinSize=1,
         DesiredCapacity=1,
         MaxSize=2
    )
    
    print("Waiting 1 minute for ASG instances to launch and become healthy...")
    time.sleep(60)  # Wait 1 minute

    # ---- Step 2: Promote the RDS Read Replica to Primary ----
    read_replica_id = os.environ['READ_REPLICA_ID']
    print(f"Promoting RDS read replica {read_replica_id}...")
    promotion_response = rds.promote_read_replica(DBInstanceIdentifier=read_replica_id)
    print("Promotion initiated:", promotion_response)
    
    print("Waiting for the promoted DB instance to become available...")
    rds.get_waiter('db_instance_available').wait(DBInstanceIdentifier=read_replica_id)
    
    db_info = rds.describe_db_instances(DBInstanceIdentifier=read_replica_id)
    db_endpoint = db_info['DBInstances'][0]['Endpoint']['Address']
    print("Promoted DB endpoint (URL):", db_endpoint)

    # Notify admin that failover is complete
    sns.publish(TopicArn=sns_topic_arn, Message="Failover complete. Failover process is complete.")
    
    return {"status": "Failover complete", "db_endpoint": db_endpoint}
