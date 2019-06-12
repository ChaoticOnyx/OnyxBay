#!/bin/bash
source /home/ubuntu/.profile
EXTERNALIP="$(curl http://ifconfig.me/ip)"
TIMESTAMP=$(date --utc +%FT%TZ)
WEBHOOK_DATA='{
  "embeds": [
    {
      "title": "AWS: Stage deployment ready",
      "description": "Stage deployment ready. To connect use this url: byond://'"$EXTERNALIP"':2507",
      "color": 3066993,
      "timestamp": "2019-05-26T17:02:30.607Z",
      "author": {
        "name": "AWS",
        "icon_url": "https://cdn.freebiesupply.com/logos/large/2x/aws-codedeploy-logo-png-transparent.png"
      }
    }
  ]
}'

curl -A "AWS" -H "Content-Type: application/json" -X POST -d "$WEBHOOK_DATA" $WEBHOOK_URL