#!/bin/sh

#  ci_post_xcodebuild.sh
#  posepicker
#
#  Created by 박경준 on 5/28/24.
#  

# Discord Webhook URL
WEBHOOK_URL="https://discord.com/api/webhooks/1244900222774280232/K6VVRQ36QG6KzkXhCvGMvPYsXW-2rJ06hKuAG-aa_H9wEyKwJLmmXiDZ9dJ4FTumMzxd"

# 메시지 내용 설정
# 빌드 상태 확인 및 메시지 설정
if [ "$CI_BUILD_STATUS" = "success" ]; then
    MESSAGE="**Build succeeded!**\n- Project: \`PosePicker\`\n- Branch: \`$CI_BRANCH\`\n- Commit: \`$CI_COMMIT\`\n\n[View Build]($CI_BUILD_URL)"
elif [ "$CI_BUILD_STATUS" = "failure" ]; then
    MESSAGE="**Build failed!**\n- Project: \`PosePicker\`\n- Branch: \`$CI_BRANCH\`\n- Commit: \`$CI_COMMIT\`\n\nPlease check the [build logs]($CI_BUILD_URL) for more details."
else
    MESSAGE="**Build status unknown.**"
fi

# Discord로 메시지 전송
curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"$MESSAGE\"}" $WEBHOOK_URL
