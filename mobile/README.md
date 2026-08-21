# تطبيق TV Stream — Flutter

هذا المجلد يحتوي على طبقة الواجهة وتدفق التشغيل في نسخة Flutter الأولى. تم فصل `ChannelApi` عن الشاشات، و`FavoritesStore` عن منطق العرض، و`HlsPlayer` عن صفحة التفاصيل.

قبل التشغيل ثبّت Flutter SDK ثم نفّذ:

```bash
flutter create --platforms=android,web .
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

استخدم `http://localhost:8000` عند تشغيل Flutter Web، واستخدم عنوان الشبكة المحلية لجهاز Backend عند التشغيل على هاتف فعلي. عنوان Android Emulator المعتاد للوصول إلى خدمة المضيف هو `10.0.2.2`.

لا يُظهر التطبيق مشغل HLS إلا عندما يعلن الـAPI أن القناة `has_playable_stream=true`. القنوات ذات `official_source` تفتح صفحة القناة الرسمية بدل إعادة توزيع رابط داخلي.
