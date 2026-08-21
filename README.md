# TV Stream

نسخة MVP من تطبيق عربي لعرض القنوات التلفزيونية التي تملك مصدر مشاهدة رسميًا، مع فصل واضح بين المشاهدة من المصدر الأصلي وتشغيل HLS المصرح به. المشروع لا يستخدم قوائم IPTV مجهولة، ولا يستخرج روابط مخفية، ولا يتجاوز DRM أو القيود التي يضعها صاحب الحقوق.

## مكونات المستودع

| المسار | الوظيفة |
|---|---|
| `mobile/` | تطبيق Flutter بواجهة عربية RTL وDark Mode ومفضلة محلية ومشغل HLS |
| `backend/` | REST API بـFastAPI وSQLAlchemy وAlembic |
| `admin/` | لوحة HTML صغيرة لإدارة القنوات والمصادر والحالات |
| `data/CHANNEL_RESEARCH.md` | تقرير البحث ومراجع المصادر وحالة الحقوق |
| `data/channels_seed.json` | القنوات الأولية التي تم التحقق من صفحاتها الرسمية |
| `docs/architecture.md` | قرارات البنية وتدفق البيانات |

## تشغيل Backend محليًا بدون Docker

```bash
cd backend
python3 -m venv .venv
. .venv/bin/activate
pip install -r requirements.txt
export DATABASE_URL=sqlite:///./tv_stream.db
export ADMIN_API_KEY=change-me
PYTHONPATH=. python scripts/seed.py
PYTHONPATH=. uvicorn app.main:app --reload --port 8000
```

سيصبح التوثيق التفاعلي متاحًا على `http://localhost:8000/docs`. في الإنتاج استخدم PostgreSQL، واضبط `DATABASE_URL` على اتصال `postgresql+psycopg`، وشغّل الهجرة عبر `alembic upgrade head` قبل تعبئة البيانات.

## تشغيل PostgreSQL وBackend عبر Docker Compose

```bash
docker compose up --build
```

بعد التشغيل، يمكن فحص الخدمة عبر `http://localhost:8000/health`. تُحمّل البيانات الأولية داخل حاوية Backend بالأمر التالي:

```bash
docker compose exec backend python scripts/seed.py
```

## تشغيل تطبيق Flutter

يتطلب مجلد `mobile/` Flutter SDK حديثًا. إذا كانت ملفات Android وiOS غير موجودة في بيئة التطوير، أنشئ ملفات المنصات مرة واحدة عبر:

```bash
cd mobile
flutter create --platforms=android,web .
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

عند التشغيل على جهاز فعلي استبدل `API_BASE_URL` بعنوان الجهاز الذي يشغل Backend. مشغل الفيديو يعمل فقط عندما يعيد الـAPI `stream_url` لقناة حالتها `verified`; أما `official_source` فيفتح صفحة القناة الرسمية بواسطة المتصفح.

## لوحة الإدارة

افتح `admin/index.html` في المتصفح، وأدخل عنوان الـAPI ومفتاح `ADMIN_API_KEY`. يجب عدم نشر لوحة الإدارة دون حماية إضافية أو استخدام مفتاح قوي؛ الحماية الحالية مخصصة للـMVP والتشغيل الداخلي.

## الواجهات

| الطريقة | المسار | الاستخدام |
|---|---|---|
| `GET` | `/health` | فحص الخدمة |
| `GET` | `/api/channels` | القنوات العامة النشطة ذات المصادر المناسبة |
| `GET` | `/api/channels?category=Kids` | التصفية حسب التصنيف |
| `GET` | `/api/channels?q=...` | البحث بالاسم أو الدولة أو التصنيف |
| `GET` | `/api/channels/search?q=...` | نقطة بحث صريحة |
| `GET` | `/api/channels/{id}` | تفاصيل القناة، مع إخفاء الرابط غير المصرح |
| `GET` | `/api/categories` | التصنيفات المتاحة |
| `GET` | `/api/admin/channels` | كل القنوات للإدارة، مع `X-Admin-Key` |
| `POST` | `/api/admin/channels` | إنشاء قناة، مع `X-Admin-Key` |
| `PUT` | `/api/admin/channels/{id}` | تحديث قناة، مع `X-Admin-Key` |
| `DELETE` | `/api/admin/channels/{id}` | حذف قناة، مع `X-Admin-Key` |
| `POST` | `/api/admin/channels/{id}/health-check` | فحص HLS وتحديث الحالة، مع `X-Admin-Key` |

## الاختبار

```bash
cd /home/ubuntu/tv-stream
PYTHONPATH=backend pytest -q backend/tests
```

تم تضمين مصدر Mux Test Streams في البيانات كاختبار HLS تقني غير نشط، وليس كقناة عربية إنتاجية. أما القنوات ذات صفحات البث الرسمية دون تصريح إعادة توزيع واضح فتبقى بحالة `permission_required` أو `official_source` ولا تُمرر روابطها الداخلية إلى المشغل.

## بناء APK صغير

لإنتاج نسخة arm64 مناسبة لمعظم أجهزة Android الحديثة مع تقليل الكود والموارد، استخدم:

```bash
cd mobile
export ANDROID_SDK_ROOT=/path/to/android-sdk
export JAVA_HOME=/path/to/jdk-21
flutter build apk --release --target-platform android-arm64 --split-per-abi
```

إعدادات Android تفعّل R8 و`shrinkResources` وتستخدم Gradle بذاكرة وعمال محدودين. النسخة التجريبية الحالية `app-arm64-v8a-release.apk` حجمها نحو 20 MB، وتتضمن أيقونة TV Stream المخصصة وأيقونات launcher بأحجام Android القياسية. هذه النسخة موقعة بمفتاح debug للتجربة فقط، ويجب استخدام توقيع release خاص قبل النشر.

## الخطوة التالية

قبل تفعيل أي قناة إنتاجية داخل المشغل، يجب الحصول على تصريح مكتوب يحدد إعادة التضمين أو إعادة التوزيع ونطاق الدول المسموح بها. بعدها تُحدّث القناة من لوحة الإدارة إلى `verified` فقط إذا كان التصريح يغطي ذلك المصدر تحديدًا.
