# Create the EventBridge rule
resource "aws_cloudwatch_event_rule" "failover_rule" {
  name        = var.rule_name
  description = var.rule_description
  event_pattern = var.event_pattern
}

# Set the Lambda function as the target for the rule
resource "aws_cloudwatch_event_target" "failover_target" {
  rule      = aws_cloudwatch_event_rule.failover_rule.name
  target_id = var.target_id
  arn       = var.lambda_function_arn
}

# Allow EventBridge to invoke the Lambda function
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.failover_rule.arn
}
