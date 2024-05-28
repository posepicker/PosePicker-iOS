#!/bin/sh

#  ci_post_xcodebuild.sh
#  posepicker
#
#  Created by 박경준 on 5/28/24.
#  

# Discord Webhook URL
WEBHOOK_URL="https://discord.com/api/webhooks/1244900222774280232/K6VVRQ36QG6KzkXhCvGMvPYsXW-2rJ06hKuAG-aa_H9wEyKwJLmmXiDZ9dJ4FTumMzxd"

# 메시지 내용 설정
MESSAGE="Build completed successfully!"

# Discord로 메시지 전송
curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"$MESSAGE\"}" $WEBHOOK_URL
