# Live Subtitle Translator

فيه طريقتين لبناء وتثبيت المشروع ده. اختار واحدة:

- **[الطريقة أ: عندك وصول لماك](#الطريقة-أ-البناء-من-خلال-xcode-على-ماك)**
- **[الطريقة ب: من غير ماك خالص (GitHub Actions + Sideloadly)](#الطريقة-ب-البناء-من-غير-ماك-github-actions--sideloadly)**

---

# الطريقة أ: البناء من خلال Xcode على ماك

الكود ده اتكتب على ويندوز، محتاج يتجمّع ويتظبط على **ماك فيه Xcode 15.4 أو أحدث**
(لأن Translation framework محتاج iOS 17.4+). هوصفلك الخطوات كاملة بالترتيب.

## 1. إنشاء المشروع والـ Targets

1. Xcode > New Project > iOS > App، اسمه `LiveSubtitleTranslator`، الواجهة SwiftUI.
2. من داخل المشروع: File > New > Target > **Broadcast Upload Extension**
   (سمّيه مثلاً `BroadcastExtension`). Xcode هيسألك "Activate scheme؟" اختار Activate.
3. File > New > Target > **Widget Extension**، وفي الشاشة اللي بتظهر
   فعّل تشييك **"Include Live Activity"**. (سمّيه `WidgetExtension`).

بعد كده هيبقى عندك 3 targets: التطبيق الرئيسي، BroadcastExtension، WidgetExtension.

## 2. نسخ الملفات

- محتويات مجلد `App/` → ضيفها للـ target الرئيسي (احذف أي ملفات افتراضية زي
  `ContentView.swift` الجاهزة واستبدلها بالنسخة هنا).
- محتويات مجلد `BroadcastExtension/` → استبدل بيها `SampleHandler.swift` اللي
  Xcode عمله تلقائي جوه target الـ BroadcastExtension.
- محتويات مجلد `WidgetExtension/` → ضيفها لـ target الـ WidgetExtension (احذف
  الملفات الافتراضية اللي مش محتاجها).
- محتويات مجلد `Shared/` → **مهم جدًا**: كل ملف فيها لازم يبقى Target Membership
  بتاعه شامل التطبيق الرئيسي + BroadcastExtension + WidgetExtension (حسب مين
  محتاج يستخدمه — راجع التعليق جوه كل ملف). بتظبط ده من File Inspector
  (الجزء اليمين في Xcode) لما تدوس على الملف.

## 3. App Groups

1. على target التطبيق الرئيسي: Signing & Capabilities > + Capability > App Groups
   > أضف group جديد زي `group.com.yourcompany.livesubtitletranslator`.
2. كرر نفس الخطوة بالظبط على target الـ BroadcastExtension (لازم يكون نفس الـ
   group identifier بالظبط).
3. حدّث القيمة في `Shared/AppGroup.swift` لتطابق الـ identifier اللي اخترته.

## 4. ربط الـ Bundle Identifiers

- في `App/BroadcastPickerView.swift`، غيّر `preferredExtension` ليطابق الـ
  Bundle Identifier الفعلي بتاع target الـ BroadcastExtension (تلاقيه في
  General > Identity بتاع الـ target).

## 5. إعدادات إضافية

- في Info.plist بتاع التطبيق الرئيسي: أضف مفتاح
  `NSSupportsLiveActivities` = `YES`.
- Deployment Target لكل الـ targets: iOS 17.4 أو أحدث.

## 6. التشغيل والتجربة

- **لازم جهاز آيفون حقيقي**، مش سيميوليتر — تسجيل/بث شاشة تطبيقات تانية بشكل
  فعلي مش بيشتغل كويس على السيميوليتر.
- شغّل التطبيق، دوس على زرار الـ Broadcast Picker، اختار الإضافة بتاعتك،
  ابدأ البث، افتح أي تطبيق فيه نص إنجليزي (يوتيوب، فيديو، إلخ)، وراقب الـ
  Dynamic Island.

## نقط متوقع تحتاج ضبط بعد أول تجربة (معروفة مسبقًا)

1. **اتجاه/قص الصورة (`cropToSubtitleRegion` في SampleHandler.swift)**:
   نظام إحداثيات CIImage ممكن يخليك تحتاج تقلب أو تظبط نسبة الـ crop حسب
   الاتجاه الفعلي للفريم. جرّب واطبع صورة الـ crop لو النص مش بيتقرا.
2. **Darwin Notifications ومنع التطبيق من الإغلاق الكامل**: لو التطبيق
   الرئيسي اتقفل خالص (force quit) مش هيستقبل الإشعارات ولا يحدّث الترجمة —
   خليه شغال في الخلفية وقت الاستخدام.
3. **أول استخدام لـ Translation framework**: النظام هيطلب من المستخدم
   تنزيل حزمة اللغة (عربي) أول مرة — ده طبيعي ومتوقع من آبل.
4. **دقة الـ OCR**: `recognitionLevel = .fast` سريع بس أقل دقة من `.accurate`
   — جرّب الاتنين وشوف الفرق حسب نوع الفيديو.

---

# الطريقة ب: البناء من غير ماك (GitHub Actions + Sideloadly)

الفكرة: GitHub بيديك مجانًا جهاز ماك افتراضي لدقايق معدودة يبني فيها الكود
(عن طريق GitHub Actions)، وإنت بتاخد الناتج (ملف `.ipa`) وتثبّته على آيفونك
من ويندوز مباشرة عن طريق برنامج اسمه **Sideloadly**. مش هتلمس ماك خالص،
لكن الإعداد أطول شوية من الطريقة أ.

أضفنا ملفين لتسهيل الموضوع:
- `project.yml` — بيوصف شكل مشروع Xcode (الـ targets وإعداداتها) كملف نصي،
  بحيث أداة اسمها **XcodeGen** تقدر تبني منه مشروع Xcode حقيقي تلقائيًا —
  من غير ما تحتاج تفتح Xcode وتعمل الخطوات يدوي زي الطريقة أ.
- `.github/workflows/build-ipa.yml` — تعليمات GitHub Actions اللي بتشغّل
  XcodeGen ثم تبني التطبيق وتطلعه كملف `.ipa` جاهز للتحميل.

## 1. اعمل حساب GitHub (لو معندكش)

روح [github.com](https://github.com) واعمل حساب مجاني.

## 2. اعمل Repository جديد وارفع الملفات

1. من صفحة GitHub الرئيسية: **New repository**، سمّيه `LiveSubtitleTranslator`،
   خليه **Private** (اختياري بس أفضل)، ودوس Create.
2. جوه صفحة الـ repo الفاضية: **uploading an existing file** (لينك بيظهر في
   الصفحة نفسها) → اسحب عليه **كل محتويات مجلد المشروع** اللي بعتهولك
   (بما فيها مجلد `.github` بمجلداته الفرعية — الأباتش أحيانًا بيخفي المجلدات
   اللي بتبدأ بنقطة، فلو الرفع بالسحب مش شايف `.github`، ارفعه بشكل منفصل
   عن طريق زرار "Add file > Upload files" داخل مسار `.github/workflows` بعد
   ما تعمله يدوي من واجهة GitHub بزرار "Create new file" واكتب المسار كامل
   `.github/workflows/build-ipa.yml`).
3. اكتب أي commit message ودوس **Commit changes**.

## 3. شغّل الـ Build

1. من تبويب **Actions** أعلى صفحة الـ repo، هتلاقي workflow اسمه
   **Build Unsigned IPA**.
2. دوس عليه، ثم دوس زرار **Run workflow** (على اليمين) → **Run workflow** تاني للتأكيد.
3. استنى 5-10 دقايق. لو خلص بعلامة ✅ خضرا، تمام. لو ❌ حمرا، افتح الخطوة
   اللي فشلت واقرا رسالة الخطأ — ابعتهالي هنا لو مش فاهمها وهساعدك تصلحها
   (متوقع تحصل أخطاء بسيطة أول مرة، ده طبيعي في مشروع بني من غير Xcode فعليًا).

## 4. حمّل ملف الـ IPA

بعد ما الـ workflow يخلص بنجاح، هتلاقي في نفس صفحة الـ run تحت
**Artifacts** ملف اسمه `LiveSubtitleTranslator-ipa` — دوس عليه ينزل كملف
zip، فك ضغطه هتلاقي جواه `LiveSubtitleTranslator.ipa`.

## 5. ثبّت الـ IPA على آيفونك باستخدام Sideloadly

1. نزّل Sideloadly من الموقع الرسمي [sideloadly.io](https://sideloadly.io)
   (نسخة ويندوز) ورتّبه.
2. وصّل الآيفون بكابل USB في جهاز الويندوز.
3. افتح Sideloadly، اسحب ملف `LiveSubtitleTranslator.ipa` عليه.
4. هيطلب منك تسجل دخول بحساب Apple ID بتاعك — ده بيحصل **جوه برنامج
   Sideloadly نفسه على جهازك**، مش حاجة بتمر عليّا أو بتتبعت لأي حد تاني.
5. دوس **Start** — هيوقّع التطبيق بحساب الـ Apple ID بتاعك ويثبّته على الآيفون.
6. على الآيفون: **الإعدادات > عام > VPN وإدارة الجهاز** → دوس على حساب
   الـ Apple ID بتاعك واختار **ثق (Trust)**.
7. افتح التطبيق من الشاشة الرئيسية.

## نقط مهمة في المسار ده

- **حساب Apple ID مجاني بيخلي التطبيق شغال 7 أيام بس**، وبعدها لازم تعيد
  خطوة Sideloadly تاني (وصل الآيفون، افتح Sideloadly، Start تاني). Sideloadly
  فيه خيار "auto-refresh" لو سبته شغال وشابك بنفس شبكة الواي فاي.
- ميزة **App Groups** (اللي بنستخدمها للمشاركة بين التطبيق والـ Extension)
  عادة بتشتغل مع حساب Apple ID مجاني، لكن لو Sideloadly رفض أو دّى خطأ
  بخصوصها، هيبقى محتاج تدخل [developer.apple.com](https://developer.apple.com)
  بنفس حساب الـ Apple ID وتفعّل capability "App Groups" يدوي مرة واحدة.
- لو الـ build في GitHub Actions فشل بسبب تفاصيل في `project.yml` (زي أسماء
  مفاتيح مش مظبوطة 100%)، الغالب حل بسيط — ابعتلي رسالة الخطأ من الـ log
  وهظبطها.
