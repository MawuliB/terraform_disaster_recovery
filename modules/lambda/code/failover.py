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
    
    # Ensure the replica is available before promoting
    print(f"Checking status of RDS read replica {read_replica_id}...")
    db_status = rds.describe_db_instances(DBInstanceIdentifier=read_replica_id)['DBInstances'][0]['DBInstanceStatus']
    if db_status != 'available':
        print(f"Read replica {read_replica_id} is not available yet. Waiting...")
        rds.get_waiter('db_instance_available').wait(DBInstanceIdentifier=read_replica_id)

    # Promote the read replica
    try:
        print(f"Promoting RDS read replica {read_replica_id}...")
        promotion_response = rds.promote_read_replica(DBInstanceIdentifier=read_replica_id)
        print("Promotion initiated:", promotion_response)
    except Exception as e:
        print(f"Failed to promote read replica: {e}")
        sns.publish(TopicArn=sns_topic_arn, Message=f"Failover failed: {e}")
        return {"status": "Failover failed", "error": str(e)}
    
    print("Waiting for the promoted DB instance to become available...")
    rds.get_waiter('db_instance_available').wait(DBInstanceIdentifier=read_replica_id)
    
    # Get the new DB endpoint
    db_info = rds.describe_db_instances(DBInstanceIdentifier=read_replica_id)
    db_endpoint = db_info['DBInstances'][0]['Endpoint']['Address']
    print("Promoted DB endpoint (URL):", db_endpoint)

    # Notify admin that failover is complete
    sns.publish(TopicArn=sns_topic_arn, Message=f"Failover complete. New DB endpoint: {db_endpoint}")

    return {"status": "Failover complete", "db_endpoint": db_endpoint}
