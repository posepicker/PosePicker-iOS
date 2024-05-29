#!/bin/sh

#  ci_post_xcodebuild.sh
#  posepicker
#
#  Created by 박경준 on 5/28/24.
#  
#!/bin/sh
# Discord Webhook URL
WEBHOOK_URL="https://discord.com/api/webhooks/1244900222774280232/K6VVRQ36QG6KzkXhCvGMvPYsXW-2rJ06hKuAG-aa_H9wEyKwJLmmXiDZ9dJ4FTumMzxd"

# 환경 변수 설정
PROJECT_NAME=${CI_PROJECT:-"Unknown Project"}
BRANCH_NAME=${CI_BRANCH:-"Unknown Branch"}
COMMIT_HASH=${CI_COMMIT:-"Unknown Commit"}
BUILD_URL=${CI_BUILD_URL:-"https://ci.example.com"}
BUILD_NUMBER=${CI_BUILD_NUMBER:-"Unknown Build Number"}
WORKFLOW_NAME=${CI_WORKFLOW:-"Unknown Workflow"}

# 빌드 종료 코드 확인
EXIT_CODE=${CI_XCODEBUILD_EXIT_CODE}

# 빌드 상태 확인 및 메시지 설정
if [ "$EXIT_CODE" -eq 0 ]; then
    MESSAGE="**Build Succeeded!** 🚀\n\n"
else
    MESSAGE="**Build Failed!** ❌\n\n"
fi

# 메시지 내용 설정
MESSAGE+="**Project**: \`$PROJECT_NAME\`\n"
MESSAGE+="**Branch**: \`$BRANCH_NAME\`\n"
MESSAGE+="**Commit**: [\`$COMMIT_HASH\`](https://github.com/posepicker/PosePicker-iOS/commit/$COMMIT_HASH)\n"
MESSAGE+="**Build Number**: \`$BUILD_NUMBER\`\n"
MESSAGE+="**Workflow**: \`$WORKFLOW_NAME\`\n"
MESSAGE+="\n[View Build]($BUILD_URL)\n"

# Discord로 메시지 전송
curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"$MESSAGE\"}" $WEBHOOK_URL
