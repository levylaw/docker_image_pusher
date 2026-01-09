FROM postgres:15-alpine

# 设置 SCWS 版本
ENV SCWS_VERSION 1.2.3

# 1. 安装编译依赖
# postgresql-dev 是必须的，因为它包含了 pg_config 和编译扩展所需的头文件
RUN apk add --no-cache --virtual .build-deps \
    gcc \
    make \
    libc-dev \
    git \
    wget \
    clang \
    llvm \
    postgresql-dev

# 2. 下载并安装 SCWS (zhparser 的底层依赖)
RUN wget -q -O - http://www.xunsearch.com/scws/down/scws-$SCWS_VERSION.tar.bz2 | tar xjf - \
    && cd scws-$SCWS_VERSION \
    && ./configure \
    && make install \
    && cd .. \
    && rm -rf scws-$SCWS_VERSION

# 3. 下载并安装 zhparser
RUN git clone https://github.com/amutu/zhparser.git \
    && cd zhparser \
    && make \
    && make install \
    && cd .. \
    && rm -rf zhparser

# 4. 清理编译依赖，只保留运行时需要的库
# 注意：zhparser 运行时需要 libscws，所以不需要删除 scws 的安装结果
RUN apk del .build-deps

# (可选) 设置一些默认配置，或者拷贝初始化脚本
# COPY ./init.sql /docker-entrypoint-initdb.d/