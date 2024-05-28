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

#{
#  "webhook" : {
#    "id" : "be7e1299-940c-415b-8cc9-7013961a6c78",
#    "name" : "Xcode-Cloud",
#    "url" : "https://discord.com/api/webhooks/1244900222774280232/K6VVRQ36QG6KzkXhCvGMvPYsXW-2rJ06hKuAG-aa_H9wEyKwJLmmXiDZ9dJ4FTumMzxd"
#  },
#  "metadata" : {
#    "type" : "metadata",
#    "attributes" : {
#      "createdDate" : "2024-05-28T08:24:09.768203493Z",
#      "eventType" : "BUILD_STARTED"
#    }
#  },
#  "app" : {
#    "id" : "6474260471",
#    "type" : "apps"
#  },
#  "ciWorkflow" : {
#    "id" : "2FD68EB8-16E0-431E-B3E1-C8E22C764CBE",
#    "type" : "ciWorkflows",
#    "attributes" : {
#      "name" : "PosePicker",
#      "description" : "",
#      "lastModifiedDate" : "2024-05-28T06:44:42.91Z",
#      "isEnabled" : true,
#      "isLockedForEditing" : false
#    }
#  },
#  "ciProduct" : {
#    "id" : "62F2E06F-87CB-4E5B-B810-0116536ECB5D",
#    "type" : "ciProducts",
#    "attributes" : {
#      "name" : "posepicker",
#      "createdDate" : "2024-05-28T06:32:42.758Z",
#      "productType" : "APP"
#    }
#  },
#  "ciBuildRun" : {
#    "id" : "349aca4f-4e7a-4a9a-ae75-13812a2ac372",
#    "type" : "ciBuildRuns",
#    "attributes" : {
#      "number" : 9,
#      "createdDate" : "2024-05-28T08:23:45.676Z",
#      "startedDate" : "2024-05-28T08:24:06.708Z",
#      "sourceCommit" : {
#        "commitSha" : "10c5e40fcdad562e05ffc87a4c85651670f24161",
#        "author" : {
#          "displayName" : "Parkjju"
#        },
#        "committer" : {
#          "displayName" : "Parkjju"
#        },
#        "htmlUrl" : "https://github.com/posepicker/PosePicker-iOS/commit/10c5e40fcdad562e05ffc87a4c85651670f24161"
#      },
#      "isPullRequestBuild" : false,
#      "executionProgress" : "RUNNING"
#    }
#  },
#  "ciBuildActions" : [ {
#    "id" : "174ed7f2-d228-49da-9b17-9126a9e858e3",
#    "type" : "ciBuildActions",
#    "attributes" : {
#      "name" : "posepicker - iOS",
#      "actionType" : "TEST",
#      "issueCounts" : {
#        "analyzerWarnings" : 0,
#        "errors" : 0,
#        "testFailures" : 0,
#        "warnings" : 0
#      },
#      "executionProgress" : "PENDING",
#      "isRequiredToPass" : true
#    },
#    "relationships" : { }
#  }, {
#    "id" : "60ba4abe-e5d8-4533-acd4-991d6ff9ba0f",
#    "type" : "ciBuildActions",
#    "attributes" : {
#      "name" : "Archive - iOS",
#      "actionType" : "ARCHIVE",
#      "issueCounts" : {
#        "analyzerWarnings" : 0,
#        "errors" : 0,
#        "testFailures" : 0,
#        "warnings" : 0
#      },
#      "executionProgress" : "PENDING",
#      "isRequiredToPass" : true
#    },
#    "relationships" : { }
#  }, {
#    "id" : "ec00464f-39b5-4a34-adb0-13affbc80de1",
#    "type" : "ciBuildActions",
#    "attributes" : {
#      "name" : "Build - iOS",
#      "actionType" : "BUILD",
#      "startedDate" : "2024-05-28T08:24:06.708Z",
#      "issueCounts" : {
#        "analyzerWarnings" : 0,
#        "errors" : 0,
#        "testFailures" : 0,
#        "warnings" : 0
#      },
#      "executionProgress" : "RUNNING",
#      "isRequiredToPass" : true
#    },
#    "relationships" : { }
#  } ],
#  "scmProvider" : {
#    "type" : "scmProviders",
#    "attributes" : {
#      "scmProviderType" : {
#        "scmProviderType" : "GITHUB_CLOUD",
#        "displayName" : "GitHub",
#        "isOnPremise" : false
#      },
#      "endpoint" : "https://github.com"
#    }
#  },
#  "scmRepository" : {
#    "id" : "11cefca4-cec3-4bed-b977-3d0eaad5a596",
#    "type" : "scmRepositories",
#    "attributes" : {
#      "httpCloneUrl" : "https://github.com/posepicker/PosePicker-iOS.git",
#      "sshCloneUrl" : "ssh://git@github.com/posepicker/PosePicker-iOS.git",
#      "ownerName" : "posepicker",
#      "repositoryName" : "PosePicker-iOS"
#    }
#  },
#  "scmGitReference" : {
#    "id" : "209f1c8b-cb6d-4c96-b5c4-e656c590f318",
#    "type" : "scmGitReferences",
#    "attributes" : {
#      "name" : "main",
#      "canonicalName" : "refs/heads/main",
#      "isDeleted" : false,
#      "kind" : "BRANCH"
#    }
#  }
#}
