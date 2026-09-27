# Self-contained build environment for release APKs.
# See docker/build-release.sh for usage.
FROM eclipse-temurin:21-jdk

ARG CMDLINE_TOOLS_VERSION=13114758
ARG BUILD_TOOLS_VERSION=37.0.0
ARG PLATFORM_VERSION=37.0
ARG NDK_VERSION=29.0.14206865

RUN apt-get update \
    && apt-get install -y --no-install-recommends git unzip curl \
    && rm -rf /var/lib/apt/lists/*

ENV ANDROID_HOME=/opt/android-sdk
ENV PATH=${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/build-tools/${BUILD_TOOLS_VERSION}:${PATH}

RUN mkdir -p ${ANDROID_HOME}/cmdline-tools \
    && curl -fsSL -o /tmp/cmdline-tools.zip \
        https://dl.google.com/android/repository/commandlinetools-linux-${CMDLINE_TOOLS_VERSION}_latest.zip \
    && unzip -q /tmp/cmdline-tools.zip -d ${ANDROID_HOME}/cmdline-tools \
    && mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest \
    && rm /tmp/cmdline-tools.zip

RUN yes | sdkmanager --licenses > /dev/null \
    && sdkmanager \
        "platform-tools" \
        "platforms;android-${PLATFORM_VERSION}" \
        "build-tools;${BUILD_TOOLS_VERSION}" \
        "ndk;${NDK_VERSION}" \
    && chmod -R a+rwX ${ANDROID_HOME}

ENV GRADLE_USER_HOME=/gradle
RUN mkdir -p /gradle && chmod a+rwX /gradle

WORKDIR /src
