{
  "widgets": [
      {
          "type": "metric",
          "x": 0,
          "y": 0,
          "width": 6,
          "height": 6,
          "properties": {
              "view": "timeSeries",
              "stacked": false,
              "metrics": [
                  [ 
                      "AWS/ApplicationELB", 
                      "RequestCount", 
                      "TargetGroup", 
                      "${api_target_group}", 
                      "LoadBalancer", 
                      "${api_load_balancer}"
                  ]
              ],
              "region": "${region}",
              "title": "Request Count API"
          }
      },
      {
          "type": "metric",
          "x": 6,
          "y": 0,
          "width": 6,
          "height": 6,
          "properties": {
              "view": "timeSeries",
              "stacked": false,
              "metrics": [
                  [ 
                      "AWS/ApplicationELB", 
                      "RequestCount", 
                      "TargetGroup", 
                      "${web_target_group}", 
                      "LoadBalancer", 
                      "${web_load_balancer}"
                  ]
              ],
              "region": "${region}",
              "title": "Request Count WEB"
          }
      },
      {
          "type": "metric",
          "x": 12,
          "y": 0,
          "width": 6,
          "height": 6,
          "properties": {
              "view": "timeSeries",
              "stacked": false,
              "metrics": [
                  [ "AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", "${database_identifier}" ],
                  [ ".", "CPUUtilization", ".", "." ]
              ],
              "region": "${region}",
              "title": "Database statistics"
          }
      },
      {
          "type": "metric",
          "x": 18,
          "y": 0,
          "width": 6,
          "height": 6,
          "properties": {
              "view": "timeSeries",
              "stacked": false,
              "metrics": [
                  [ "AWS/ECS", "CPUUtilization", "ServiceName", "${api_service}", "ClusterName", "${api_cluster}" ],
                  [ ".", "MemoryUtilization", ".", ".", ".", "." ],
                  [ "...", "${web_service}", ".", "${web_cluster}" ],
                  [ ".", "CPUUtilization", ".", ".", ".", "." ]
              ],
              "region": "${region}",
              "title": "ECS statistics"
          }
      }
  ]
}