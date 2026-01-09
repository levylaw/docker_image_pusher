FROM postgres:15-alpine

# 设置 SCWS 版本
ENV SCWS_VERSION=1.2.3

# 1. 安装编译依赖
# 添加了 build-base (包含 make, gcc 等)
RUN apk add --no-cache --virtual .build-deps \
    build-base \
    git \
    wget \
    postgresql-dev \
    libc-dev

# 2. 下载并安装 SCWS
RUN wget -q -O - http://www.xunsearch.com/scws/down/scws-$SCWS_VERSION.tar.bz2 | tar xjf - \
    && cd scws-$SCWS_VERSION \
    && ./configure \
    && make install \
    && cd .. \
    && rm -rf scws-$SCWS_VERSION

# 3. 下载并安装 zhparser
# 关键修复：通过 with_llvm=no 禁用对 clang 的依赖
RUN git clone --depth 1 https://github.com/amutu/zhparser.git \
    && cd zhparser \
    && make with_llvm=no \
    && make install \
    && cd .. \
    && rm -rf zhparser

# 4. 清理编译依赖
RUN apk del .build-deps

# 5. 运行时依赖 (SCWS 编译后生成的 libscws.so 需要在运行时存在)
# 因为之前 apk del 可能会影响，我们确保 ldconfig 刷新
RUN ldconfig /usr/local/lib