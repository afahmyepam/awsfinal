resource "aws_cloudwatch_log_group" "ghost-ecs-logs" {
  name = "ghost-ecs"
}

# 11 Monitoring 

# Create CloudWatch Dashboard to agregate your infrastructure metrics:

#   EC2 Average CPU utilization for EC2 instances in ASG
#   ECS Service CPU Utilization
#   ECS Running tasks count
#   EFS ClientConnections
#   EFS StorageBytes in Mb
#   RDS DB connections
#   RDS CPU utilization
#   RDS storage read\write IOPS

resource "aws_cloudwatch_dashboard" "cloudx-ghost" {
  dashboard_name = "cloudx-ghost"
  dashboard_body = <<EOF
{
  "widgets": [
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 8,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/EC2",
            "CPUUtilization"
          ]
        ],
        "period": 60,
        "stat": "Maximum",
        "region": "eu-central-1",
        "title": "EC2|CPU Utilization"
      }
    },
    {
      "type": "metric",
      "x": 8,
      "y": 0,
      "width": 8,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/ECS/ContainerInsights",
            "CpuUtilized"
          ]
        ],
        "period": 60,
        "stat": "Maximum",
        "region": "eu-central-1",
        "title": "ECS|CPU Utilization"
      }
    },
    {
      "type": "metric",
      "x": 16,
      "y": 0,
      "width": 8,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/ECS/ContainerInsights",
            "TaskCount"
          ]
        ],
        "period": 60,
        "stat": "Maximum",
        "region": "eu-central-1",
        "title": "ECS|Task Count"
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 6,
      "width": 8,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/EFS",
            "ClientConnections"
          ]
        ],
        "period": 60,
        "stat": "Sum",
        "region": "eu-central-1",
        "title": "EFS|Client Connections"
      }
    },
    {
      "type": "metric",
      "x": 8,
      "y": 6,
      "width": 8,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/EFS",
            "StorageBytes"
          ]
        ],
        "period": 60,
        "stat": "Average",
        "region": "eu-central-1",
        "title": "EFS|Storage"
      }
    },
    {
      "type": "metric",
      "x": 8,
      "y": 6,
      "width": 8,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/RDS",
            "DatabaseConnections"
          ]
        ],
        "period": 60,
        "stat": "Average",
        "region": "eu-central-1",
        "title": "RDS|Database Connections"
      }
    },
    {
      "type": "metric",
      "x": 8,
      "y": 6,
      "width": 8,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/RDS",
            "CPUUtilization"
          ]
        ],
        "period": 60,
        "stat": "Average",
        "region": "eu-central-1",
        "title": "RDS|CPU Utilization"
      }
    },
    {
      "type": "metric",
      "x": 16,
      "y": 6,
      "width": 8,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/RDS",
            "ReadIOPS"
          ],
          [
            "AWS/RDS",
            "WriteIOPS"
          ]
        ],
        "period": 60,
        "stat": "Average",
        "region": "eu-central-1",
        "title": "RDS|Storage Read /Write IOPS"
      }
    }
  ]
}
EOF

}