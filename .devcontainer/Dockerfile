FROM ghcr.io/cirruslabs/flutter:stable

RUN apt-get update && \
    apt-get install -y clang cmake ninja-build pkg-config chromium-browser wget unzip lib32stdc++6 lib32z1 && \
    rm -rf /var/lib/apt/lists/*

# Install Android Studio
ARG ANDROID_STUDIO_VERSION=2024.1.1.21
RUN wget -q https://redirector.gvt1.com/edgedl/android/studio/ide-zips/${ANDROID_STUDIO_VERSION}/android-studio-${ANDROID_STUDIO_VERSION}-linux.tar.gz -O /tmp/android-studio.tar.gz && \
    mkdir -p /opt/android-studio && \
    tar -xzf /tmp/android-studio.tar.gz -C /opt/android-studio --strip-components=1 && \
    rm /tmp/android-studio.tar.gz && \
    ln -s /opt/android-studio/bin/studio.sh /usr/local/bin/android-studio

ENV CHROME_EXECUTABLE=/usr/bin/chromium-browser
