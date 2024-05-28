#!/bin/sh

#  ci_post_clone.sh
#  posepicker
#
#  Created by 박경준 on 5/28/24.
#

FOLDER_PATH="/Volumes/workspace/repository/posepicker/Configs"

# PARTS 배열의 두 번째 요소가 "Scheme Name"에 해당

# *.xconfig 파일 이름
CONFIG_FILENAME="posepicker.xcconfig"

# *.xconfig 파일의 전체 경로 계산
CONFIG_FILE_PATH="$FOLDER_PATH/$CONFIG_FILENAME"

# 환경 변수에서 값을 가져와서 *.xconfig 파일에 추가하기
echo "KAKAO_NATIVE_KEY = $KAKAO_NATIVE_KEY" >> "$CONFIG_FILE_PATH"
echo "SMARTLOOK_PROJECT_KEY = $SMARTLOOK_PROJECT_KEY" >> "$CONFIG_FILE_PATH"

# 생성된 *.xconfig 파일 내용 출력
cat "$CONFIG_FILE_PATH"

echo "posepicker.xcconfig 파일이 성공적으로 생성되었고, 환경변수 값이 확인되었습니다.
