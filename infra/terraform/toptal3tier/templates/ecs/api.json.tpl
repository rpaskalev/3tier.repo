[
  {
    "name": "api",
    "image": "${image}",
    "cpu": ${cpu},
    "memory": ${memory},
    "networkMode": "awsvpc",
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "toptal3tier_log_group",
        "awslogs-region": "${region}",
        "awslogs-stream-prefix": "api"
      }
    },
    "portMappings": [
      {
        "containerPort": ${port},
        "hostPort": ${port}
      }
    ],
    "environment": [
      {
        "name": "NODE_ENV",
        "value": "production"
      },
      {
        "name": "DB",
        "value": "${database_url}"
      },
      {
        "name": "PORT",
        "value": "${port}"
      }
    ]
  }
]