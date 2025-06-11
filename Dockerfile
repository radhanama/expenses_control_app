# ---- 1️⃣ builder stage: full Android+Flutter tool-chain ----
    FROM instrumentisto/flutter:3.32.2-androidsdk35-r0 AS builder
    #  └─  3.32.2 = latest stable (June 2025)  •  androidsdk35 = API 35 tools :contentReference[oaicite:0]{index=0}
    
    # Accept Android licences once so the build is non-interactive
    RUN yes | sdkmanager --licenses
    
    # Where we’ll copy your Flutter project
    WORKDIR /src
    
    # -- Dependency cache layer --
    COPY pubspec.* ./
    RUN flutter pub get
    
    # -- Source code --
    COPY . .
    
    # Build a RELEASE APK (split by ABI for smaller downloads)
    RUN flutter build apk --release --split-per-abi
    
    # ---- 2️⃣ final stage: tiny image that just holds the artefacts ----
    FROM busybox:uclibc
    COPY --from=builder /src/build/app/outputs/flutter-apk/ /dist/
    CMD ["sh", "-c", "echo '✅ APKs are inside /dist:' && ls -l /dist"]
    