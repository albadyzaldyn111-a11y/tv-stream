# Android Build — TV Stream v0.1.0

تم بناء نسخة تجريبية Release لمعمارية **arm64-v8a** باستخدام Flutter 3.47.1 وAndroid SDK 36. استخدم البناء `--split-per-abi` حتى لا تُضمّن مكتبات معمارية غير لازمة داخل الملف، مع تفعيل R8 و`shrinkResources` وتقليل عمال Gradle.

| الحقل | القيمة |
|---|---|
| الملف | `app-arm64-v8a-release.apk` |
| الحجم | نحو 20 MB |
| package | `com.example.tv_stream` |
| version | `0.1.0` / versionCode `2001` |
| minSdk | 24 |
| targetSdk | 36 |
| التوقيع | Debug signing للتجربة فقط |
| SHA-256 | `eca240a36e33da91d186a18e673652370bd273067a08d448e2b9289b6a885d15` |

> هذه النسخة مناسبة للتجربة على أجهزة Android arm64. أجهزة 32-bit تحتاج بناء ABI آخر. قبل النشر العام يجب إنشاء keystore خاص واستخدام توقيع Release، كما يجب ضبط عنوان API الحقيقي عبر إعدادات بيئة الإنتاج بدل خادم محلي.
