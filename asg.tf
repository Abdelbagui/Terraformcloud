# Déclaration du SNS Topic pour les notifications ASG
resource "aws_sns_topic" "asg_notifications" {
  name = "abdel_asg-notifications"
}