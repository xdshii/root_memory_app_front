FROM ubuntu:20.04

# 避免交互式提示
ENV DEBIAN_FRONTEND=noninteractive

# 设置代理
ENV HTTP_PROXY=http://host.docker.internal:7891
ENV HTTPS_PROXY=http://host.docker.internal:7891
ENV NO_PROXY=localhost,127.0.0.1,::1

# 安装基本工具和依赖
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    openjdk-11-jdk \
    wget \
    xauth \
    libxtst6 \
    libxrandr2 \
    libatk1.0-0 \
    libxcomposite1 \
    libdbus-glib-1-2 \
    cmake \
    ninja-build \
    clang \
    pkg-config \
    libgtk-3-dev \
    liblzma-dev \
    && apt-get clean

# 下载并安装Flutter SDK
RUN git config --global http.proxy http://host.docker.internal:7891 \
    && git config --global https.proxy http://host.docker.internal:7891 \
    && git clone https://github.com/flutter/flutter.git -b stable /flutter

# 设置Flutter环境变量
ENV FLUTTER_NO_ROOT_WARNING=true
ENV PATH="/flutter/bin:${PATH}"

# 预下载Flutter依赖
RUN flutter precache && flutter doctor

# Android SDK安装
ENV ANDROID_SDK_ROOT=/opt/android-sdk-linux
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools

# 下载和安装Android SDK命令行工具
RUN wget https://dl.google.com/android/repository/commandlinetools-linux-8092744_latest.zip -O cmdline-tools.zip && \
    unzip cmdline-tools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools && \
    rm cmdline-tools.zip && \
    mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest

# 设置环境变量
ENV PATH="${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools"

# 接受许可证
RUN mkdir -p ~/.android && touch ~/.android/repositories.cfg
RUN yes | sdkmanager --licenses

# 安装Android SDK组件
RUN sdkmanager "platform-tools" "platforms;android-31" "build-tools;30.0.3"

# 设置工作目录
WORKDIR /app

# 暴露端口
EXPOSE 8080
EXPOSE 8081
EXPOSE 5037

# 容器启动命令
CMD ["/bin/bash"]