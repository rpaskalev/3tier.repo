[
  {
    "name": "web",
    "image": "${image}",
    "cpu": ${cpu},
    "memory": ${memory},
    "networkMode": "awsvpc",
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "toptal3tier_log_group",
        "awslogs-region": "${region}",
        "awslogs-stream-prefix": "web"
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
        "name": "API_HOST",
        "value": "${api_url}"
      },
      {
        "name": "PORT",
        "value": "${port}"
      }
    ]
  }
]