# این اسکریپت کامل رو اجرا کن تا واقعاً APK ساخته بشه
cat > full-build.sh << 'EOF'
#!/bin/bash
echo "🔧 ساخت واقعی APK شروع شد..."

# نصب همه چیز از صفر
sudo apt update
sudo apt install -y openjdk-11-jdk wget unzip

# دانلود Android SDK
mkdir -p android-sdk
cd android-sdk
wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
unzip commandlinetools-linux-11076708_latest.zip
cd cmdline-tools
mkdir latest
mv bin lib NOTICE.txt source.properties latest/

export ANDROID_HOME=$(pwd)/..
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin

# قبول لایسنس
yes | sdkmanager --licenses

# نصب پلتفرم
sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.2"

# برگشت به پروژه
cd ../..

# ساخت APK
cd AutoAssistantAI
chmod +x ./gradlew
./gradlew assembleDebug

echo "✅ APK ساخته شد: app/build/outputs/apk/debug/app-debug.apk"
EOF

chmod +x full-build.sh
./full-build.sh
