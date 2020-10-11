resource "aws_cloudformation_stack" "autoscaling_group" {
  name = var.cfn_stack_name

  template_body = <<EOF
Description: "${var.cfn_stack_name}"
Resources:
  ASG:
    Type: AWS::AutoScaling::AutoScalingGroup
    Properties:
      VPCZoneIdentifier: ["${join("\",\"", [module.vpc.private_subnet_ids[0], module.vpc.private_subnet_ids[1]])}"]
      AvailabilityZones: ["${join("\",\"", var.az)}"]
      LaunchTemplate:
        LaunchTemplateName: "${aws_launch_template.LT.name}"
        Version:  "${aws_launch_template.LT.latest_version}" 
      MinSize: "${var.asg_min_size}"
      MaxSize: "${var.asg_max_size}"
      DesiredCapacity: "${var.asg_desired_capacity}"
      HealthCheckType: EC2
 
    CreationPolicy:
      AutoScalingCreationPolicy:
        MinSuccessfulInstancesPercent: 80
      ResourceSignal:
        Count: "${var.cfn_signal_count}"
        Timeout: PT10M
    UpdatePolicy:
    # Ignore differences in group size properties caused by scheduled actions
      AutoScalingScheduledAction:
        IgnoreUnmodifiedGroupSizeProperties: true
      AutoScalingRollingUpdate:
        MaxBatchSize: "${var.asg_max_size}"
        MinInstancesInService: "${var.asg_min_size}"
        MinSuccessfulInstancesPercent: 80
        PauseTime: PT10M
        SuspendProcesses:
          - HealthCheck
          - ReplaceUnhealthy
          - AZRebalance
          - AlarmNotification
          - ScheduledActions
        WaitOnResourceSignals: true
    DeletionPolicy: Retain
  EOF
}