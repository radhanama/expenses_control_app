FROM instrumentisto/flutter:3.32.2-androidsdk35-r0 AS builder
RUN yes | sdkmanager --licenses
WORKDIR /src

# -- dependency‑cache layer --
COPY pubspec.* ./
# also copy any local‑path packages referenced in pubspec
RUN flutter pub get

# -- source --
COPY . .

RUN flutter build apk --release --split-per-abi

# ---- 2️⃣ final stage: tiny image that just holds the artefacts ----
FROM busybox:uclibc
COPY --from=builder /src/build/app/outputs/flutter-apk/ /dist/
CMD ["sh", "-c", "echo '✅ APKs are inside /dist:' && ls -l /dist"]
