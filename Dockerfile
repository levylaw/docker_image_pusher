FROM postgres:16-bookworm

# 设置 SCWS 版本
ENV SCWS_VERSION=1.2.3

# 1. 安装编译依赖
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    wget \
    libpq-dev \
    libc-dev \
    && rm -rf /var/lib/apt/lists/*

# 2. 下载并安装 SCWS
RUN wget -q -O - http://www.xunsearch.com/scws/down/scws-$SCWS_VERSION.tar.bz2 | tar xjf - \
    && cd scws-$SCWS_VERSION \
    && ./configure \
    && make install \
    && cd .. \
    && rm -rf scws-$SCWS_VERSION

# 3. 下载并安装 zhparser
RUN git clone --depth 1 https://github.com/amutu/zhparser.git \
    && cd zhparser \
    && make \
    && make install \
    && cd .. \
    && rm -rf zhparser

# 4. 清理编译依赖
RUN apt-get remove -y build-essential git wget libpq-dev libc-dev \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# 5. 运行时依赖
RUN ldconfig /usr/local/lib