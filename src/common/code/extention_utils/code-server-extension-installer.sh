#!/bin/bash

set -eu

function usage {
  cat <<EOM
Usage: $(basename "$0") [OPTION]...
  -h             ... Display help
  -r filepath     ... Requirements file path
EOM
  exit 2
}

#スクリプトパス取得
CURRENT=$(cd $(dirname $0);pwd)

FILEPATH=""

# 引数別の処理定義
while getopts ":r:h" optKey; do
  case "$optKey" in
    r)
      FILEPATH=${OPTARG}
      ;;

    '-h'|'--help'|* )
      usage
      ;;
  esac
done

CR=$(printf '\r')
while IFS= read -r line && line=${line%"$CR"} || [ "$line" ]; do
  if [[ "${line}" == "#"*  || -z "${line}" ]]; then
    echo "Skip line"
  else
    if [[ "${line}" == "http://"*  || "${line}" == "https://"* ]]; then
      # URLの時の処理
      curl -O ${line}
      mv vspackage vspackage.gz
      gunzip -v vspackage.gz
      if [ -e "vspackage.gz" ]; then
        echo "gzip error"
        exit 1
      fi
      mv vspackage vspackage.vsix
      /usr/bin/code-server --install-extension vspackage.vsix
      rm vspackage.vsix
    elif [[ "${line}" == *".vsix" ]]; then
      # ファイルからインストールするとき
      if [ ! -e "${CURRENT}/vsix/${line}" ]; then
        echo "${line} does not exist."
        exit 1
      fi
      /usr/bin/code-server --install-extension ${CURRENT}/vsix/${line}
    else
      #URLでもファイルでもないとき
      /usr/bin/code-server --install-extension ${line}
    fi
  fi

done < ${FILEPATH}

exit 0
