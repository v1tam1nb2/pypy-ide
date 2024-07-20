# ベースとなるイメージ
FROM ubuntu:22.04

# インストールするPythonのバージョン
# インストールするcode-serverのバージョン
ARG PYPY_VERSION=pypy3.10-7.3.16 \
    CODE_SERVER_VERSION=4.90.3


# プロキシ環境変数
# --build-argでの上書き
ARG http_proxy= \
    no_proxy= \
    https_proxy=${http_proxy} \
    HTTP_PROXY=${http_proxy} \
    HTTPS_PROXY=${https_proxy} \
    NO_PROXY=${no_proxy}


# 非インタラクティブに設定
ENV DEBIAN_FRONTEND="noninteractive"

# code-serverに拡張機能をインストールするためのファイルコピー
COPY ./src/common/code/extention_utils /dockerbuild/code-server/extention_utils
COPY ./src/common/code/ruff /root/.config/ruff

# 基本的に変更されない共通インストール処理
RUN echo "##############################" && \
    echo "###### set temp proxy ######" && \
    echo "##############################" && \
    export http_proxy=${http_proxy}; HTTP_PROXY=${HTTP_PROXY}; https_proxy=${https_proxy}; HTTPS_PROXY=${HTTPS_PROXY}; no_proxy=${no_proxy}; NO_PROXY=${NO_PROXY} && \
    echo "##############################" && \
    echo "###### install common utils ######" && \
    echo "##############################" && \
    apt-get update && apt-get upgrade -y && \
    apt-get install -y wget curl vim emacs-nox openssl git iproute2 iputils-ping net-tools zip subversion && \
    echo "##############################" && \
    echo "###### install OpenJDK ######" && \
    echo "##############################" && \
    apt-get install -y openjdk-8-jdk maven && \
    echo "##############################" && \
    echo "###### install code-server ######" && \
    echo "##############################" && \
    curl -fsSL https://code-server.dev/install.sh | sh -s -- --version ${CODE_SERVER_VERSION} && \
    echo "##############################" && \
    echo "###### install Python ######" && \
    echo "##############################" && \
    apt-get install -y build-essential libbz2-dev libdb-dev libreadline-dev libffi-dev libgdbm-dev liblzma-dev libncursesw5-dev libsqlite3-dev libssl-dev zlib1g-dev uuid-dev && \
    cd && git clone https://github.com/pyenv/pyenv.git -b master --depth 1 && \
    pyenv/plugins/python-build/bin/python-build ${PYPY_VERSION} /usr/local && \
    pip install -U pip  && pip install wheel && \
    rm -rf pyenv && \
    echo "##############################" && \
    echo "###### install nginx ######" && \
    echo "##############################" && \
    groupadd nginx && \
    useradd -g nginx nginx && \
    usermod -s /bin/false nginx && \
    apt-get install -y nginx && \
    echo "##############################" && \
    echo "###### install supervisor ######" && \
    echo "##############################" && \
    pip install supervisor && \
    echo_supervisord_conf > /etc/supervisord.conf && \
    mkdir /etc/supervisord.d && \
    sed -i 's/nodaemon=false/nodaemon=true/' /etc/supervisord.conf && \
    sed -i "s/;\[include\]/\[include\]/" /etc/supervisord.conf && \
    sed -i "s/;files = relative\/directory\/\*\.ini/files = supervisord.d\/*.ini/" /etc/supervisord.conf && \
    echo "##############################" && \
    echo "###### install code-server extentions ######" && \
    echo "##############################" && \
    chmod u+x /dockerbuild/code-server/extention_utils/code-server-extension-installer.sh && \
    /dockerbuild/code-server/extention_utils/code-server-extension-installer.sh -r /dockerbuild/code-server/extention_utils/code-server-extensions.txt && \
    echo "##############################" && \
    echo "###### set locale ######" && \
    echo "##############################" && \
    apt-get install -y language-pack-ja-base language-pack-ja locales && \
    localedef -f UTF-8 -i ja_JP ja_JP.UTF-8 && \
    echo "##############################" && \
    echo "###### clean up ######" && \
    echo "##############################" && \
    rm -rf /root/.cache && \
    apt-get autoremove && apt-get autoclean && apt-get clean && rm -rf /var/lib/apt/lists/*

# Pythonにインストールするmoduleのrequirements.txtのコピー
COPY ./src/common/python/requirements/common.txt /tmp/requirements/common.txt

# Pythonモジュールのインストール
RUN echo "##############################" && \
    echo "###### set temp proxy ######" && \
    echo "##############################" && \
    export http_proxy=${http_proxy}; HTTP_PROXY=${HTTP_PROXY}; https_proxy=${https_proxy}; HTTPS_PROXY=${HTTPS_PROXY}; no_proxy=${no_proxy}; NO_PROXY=${NO_PROXY} && \
    echo "##############################" && \
    echo "###### install Python common modules ######" && \
    echo "##############################" && \
    pip install -r /tmp/requirements/common.txt  && \
    echo "##############################" && \
    echo "###### clean up ######" && \
    echo "##############################" && \
    rm -rf /root/.cache && rm -rf /tmp/*

# 必須ファイルコピー
COPY ./src/common/code/User /root/.local/share/code-server/User
COPY ./src/common/code/Machine /root/.local/share/code-server/Machine
COPY ./src/common/code/languagepacks.json /root/.local/share/code-server/languagepacks.json
COPY ./src/common/supervisor /etc/supervisord.d
COPY ./src/common/scripts /dockerstartup
COPY ./src/common/nginx/default.d /etc/nginx/default.d
COPY ./src/common/nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./src/common/nginx/top/html /usr/share/nginx/html

# コピー後の権限設定
RUN chmod -R 755 /etc/nginx && \
    chmod -R 755 /dockerstartup

# 非インタラクティブ解除
ENV DEBIAN_FRONTEND="" \
    TZ="Asia/Tokyo" \
    LANG="ja_JP.UTF-8" \
    LC_ALL="ja_JP.UTF-8" \
    LANGUAGE="ja_JP:ja" \
    JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"


# コンテナ起動時の実行コマンド設定
ENTRYPOINT [ "/usr/local/bin/supervisord" ]
