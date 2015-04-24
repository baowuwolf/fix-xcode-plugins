#!/bin/sh

# 插件的目录
PluginDir="$HOME/Library/Application Support/Developer/Shared/Xcode/Plug-ins/"

# 修正插件
function fixPlugin
{
    UUID=`echo "$*" | awk -F "|" '{print $1}'`
    Plugin=`echo "$*" | awk -F "|" '{print $2}'`
    Key=`echo "$*" | awk -F "|" '{print $3}'`

    Plugin=${Plugin//\"/}
    Plist="$PluginDir""$Plugin"/Contents/Info.plist
    echo "try fix plug-in : "$Plugin""

     echo "$Plist"
    if [[ -e "$Plist" ]]; then
        `/usr/libexec/PlistBuddy -c "ADD $Key array" "$Plist" 2>0`
        `/usr/libexec/PlistBuddy -c "ADD $Key:0 string $UUID" "$Plist"`
    else
        echo "$Plist" " not exist"
    fi
}

# 对xcode结果进行过滤
if [[ -e $1 ]]; then
    REPORT=`cat $1|grep "Required plug-in compatibility UUID"`
 else
    REPORT=`xcodebuild -showsdks 2>&1 1>/dev/null | grep "Required plug-in compatibility UUID"`
fi
#echo "check result: $REPORT"
# 检查是否需要过滤
if [[ -z $REPORT ]]; then
    #statements
    echo "excellent"
    exit 0
fi

# 逐个遍历，并尝试修复
while read LINE
do
    PARAM=`echo "$LINE"|sed -E "s/.*UUID (.{36}) .*Plug-ins\/(.*)' not present in (.*)/\1|\2|\3/"`
    echo "param: " $PARAM
    fixPlugin $PARAM
done <<< "$REPORT"

# 确认修复结果
REPORT=`xcodebuild -showsdks 2>&1 1>/dev/null | grep "Required plug-in compatibility UUID"`
if [[ -z $REPORT ]]; then
  echo "success"
else
  echo "sorry"
fi