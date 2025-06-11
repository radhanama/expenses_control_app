# ---- Builder stage ----------------------------------------------------------
    FROM instrumentisto/flutter:3.32.2-androidsdk35-r0 AS builder

    # 1️⃣  Install Java 17 and make it the default
    RUN apt-get update && apt-get install -y openjdk-17-jdk && \
        update-alternatives --set java /usr/lib/jvm/java-17-openjdk-amd64/bin/java && \
        update-alternatives --set javac /usr/lib/jvm/java-17-openjdk-amd64/bin/javac
    
    ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
    ENV PATH="$JAVA_HOME/bin:${PATH}"
    
    # 2️⃣  Accept Android licences so Gradle won’t prompt
    RUN yes | sdkmanager --licenses
    
    # 3️⃣  Build your app
    WORKDIR /src
    COPY . .
    RUN flutter pub get
    RUN flutter build apk --release --split-per-abi
    
    # ---- Tiny stage with the artefacts ------------------------------------------
    FROM busybox:uclibc
    COPY --from=builder /src/build/app/outputs/flutter-apk/ /dist/
    CMD ["sh", "-c", "echo '✅ APKs ready in /dist:' && ls -l /dist"]
    