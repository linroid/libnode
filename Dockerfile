# FROM i386/ubuntu:18.04
FROM ubuntu:18.04

ENV ANDROID_NDK_HOME /opt/android-ndk
ENV ANDROID_NDK_VERSION r20b
ARG NODE_VERSION=v16.7.0

# Install required tools
RUN apt-get update -qq \
  && apt-get clean \
  && apt-get install curl git unzip python g++ gcc make gcc-multilib g++-multilib lib32z1 python3-pip python3-dev -y

# Download and unpress NDK
RUN mkdir /opt/android-ndk-tmp && \
    curl -o /opt/android-ndk-tmp/android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip  https://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip && \
    cd /opt/android-ndk-tmp && \
    unzip -q android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip && \
    mv ./android-ndk-${ANDROID_NDK_VERSION} ${ANDROID_NDK_HOME} && \
    rm -rf /opt/android-ndk-tmp

# Download node source
RUN curl https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}.tar.gz | tar -xz  -C /

# Set environments
RUN mkdir -p /output
ENV PATH ${PATH}:${ANDROID_NDK_HOME}
ENV NODE_SOURCE_PATH /node-${NODE_VERSION}
