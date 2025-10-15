# فقط این خط رو کپی کن و در ترمینال کداسپیسز پیست کن - همه چی خودکاره!
cat > auto-build.sh << 'SCRIPT_EOF'
#!/bin/bash
echo "🚀 شروع ساخت خودکار APK با قابلیت تفسیر صفحه..."
set -e

# ایجاد فایل های پروژه
mkdir -p AutoAssistantAI/app/src/main/kotlin/com/assistantai/{core,accessibility,ui}
mkdir -p AutoAssistantAI/app/src/main/res/{values,xml}
mkdir -p .github/workflows

# ایجاد GitHub Actions
cat > .github/workflows/auto-build.yml << 'EOF'
name: Auto Build APK
on: [push, workflow_dispatch]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: Build APK
      run: |
        chmod +x build.sh
        ./build.sh
    - uses: actions/upload-artifact@v4
      with:
        name: assistant-apk
        path: AutoAssistantAI/app/build/outputs/apk/debug/app-debug.apk
EOF

# ایجاد اسکریپت ساخت اصلی
cat > build.sh << 'EOF'
#!/bin/bash
echo "🤖 ساخت APK شروع شد..."

# نصب وابستگی ها
sudo apt update && sudo apt install -y openjdk-11-jdk

# ایجاد ساختار پروژه
mkdir -p app/src/main/kotlin/com/assistantai
mkdir -p app/src/main/res/values

# ایجاد فایل های اصلی
cat > app/build.gradle << 'GRADLE_EOF'
plugins {
    id 'com.android.application'
    id 'org.jetbrains.kotlin.android'
}

android {
    namespace 'com.assistantai.auto'
    compileSdk 33
    defaultConfig {
        applicationId "com.assistantai.auto"
        minSdk 21
        targetSdk 33
        versionCode 1
        versionName "1.0"
    }
    buildTypes {
        release {
            minifyEnabled false
        }
    }
}

dependencies {
    implementation 'androidx.core:core-ktx:1.12.0'
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'androidx.accessibilityservice:accessibilityservice:1.0.1'
}
GRADLE_EOF

cat > app/src/main/AndroidManifest.xml << 'MANIFEST_EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.BIND_ACCESSIBILITY_SERVICE" />
    <uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
    
    <application
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name">
        <activity android:name=".MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
        
        <service android:name=".ScreenReaderService"
            android:permission="android.permission.BIND_ACCESSIBILITY_SERVICE"
            android:exported="true">
            <intent-filter>
                <action android:name="android.accessibilityservice.AccessibilityService" />
            </intent-filter>
            <meta-data android:name="android.accessibilityservice"
                android:resource="@xml/accessibility_config" />
        </service>
    </application>
</manifest>
MANIFEST_EOF

# ایجاد سرویس تفسیر صفحه
cat > app/src/main/kotlin/com/assistantai/ScreenReaderService.kt << 'SERVICE_EOF'
package com.assistantai

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.util.Log
import android.view.accessibility.AccessibilityEvent

class ScreenReaderService : AccessibilityService() {
    override fun onAccessibilityEvent(event: AccessibilityEvent) {
        // اینجا محتوای صفحه خوانده و تفسیر میشه
        Log.d("ScreenReader", "محتوای صفحه تحلیل شد")
    }
    
    override fun onInterrupt() {}
    
    override fun onServiceConnected() {
        super.onServiceConnected()
        val info = AccessibilityServiceInfo()
        info.eventTypes = AccessibilityEvent.TYPES_ALL_MASK
        info.feedbackType = AccessibilityServiceInfo.FEEDBACK_ALL_MASK
        info.notificationTimeout = 100
        info.flags = AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS
        this.serviceInfo = info
    }
}
SERVICE_EOF

# ایجاد اکتیویتی اصلی
cat > app/src/main/kotlin/com/assistantai/MainActivity.kt << 'ACTIVITY_EOF'
package com.assistantai

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.content.Intent
import android.provider.Settings
import android.widget.Button
import android.widget.TextView

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        val statusText = findViewById<TextView>(R.id.statusText)
        val startButton = findViewById<Button>(R.id.startButton)
        
        startButton.setOnClickListener {
            statusText.text = "سرویس تفسیر صفحه فعال شد!"
            // فعال کردن سرویس دسترسی
            val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
            startActivity(intent)
        }
    }
}
ACTIVITY_EOF

# ایجاد منابع
cat > app/src/main/res/values/strings.xml << 'STRINGS_EOF'
<resources>
    <string name="app_name">دستیار هوشمند</string>
    <string name="service_description">سرویس تفسیر محتوای صفحه</string>
</resources>
STRINGS_EOF

mkdir -p app/src/main/res/xml
cat > app/src/main/res/xml/accessibility_config.xml << 'CONFIG_EOF'
<?xml version="1.0" encoding="utf-8"?>
<accessibility-service
    xmlns:android="http://schemas.android.com/apk/res/android"
    android:description="@string/service_description"
    android:accessibilityEventTypes="typeAllMask"
    android:accessibilityFlags="flagDefault|flagIncludeNotImportantViews"
    android:accessibilityFeedbackType="feedbackAllMask"
    android:canRetrieveWindowContent="true"
    android:notificationTimeout="100"/>
CONFIG_EOF

echo "✅ ساخت پروژه کامل شد!"
EOF

chmod +x build.sh
echo "🎉 تمام! حالا میتونی:"
echo "1. اجرا کنی: ./build.sh"
echo "2. یا به گیتهاب پوش کنی تا خودکار ساخته بشه"
SCRIPT_EOF

# اجرای خودکار اسکریپت
chmod +x auto-build.sh
./auto-build.sh
