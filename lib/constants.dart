import 'package:flutter/material.dart';

// الألوان الأساسية الجديدة
const colorWhite = Colors.white;
Color colorSpecialGrey = Colors.grey.shade300;
Color colorBackground = Color(0xFFF8FAFF); // خلفية فاتحة مع لون أزرق خفيف

// الألوان الرئيسية الجديدة
const colorPrimary = Color(0xFF667EEA); // أزرق بنفسجي جميل
const colorSecondary = Color(0xFF764BA2); // بنفسجي غامق
const colorAccent = Color(0xFFF093FB); // وردي فاتح
const colorSuccess = Color(0xFF4CAF50); // أخضر
const colorWarning = Color(0xFFFF9800); // برتقالي
const colorError = Color(0xFFE57373); // أحمر فاتح
const colorInfo = Color(0xFF64B5F6); // أزرق فاتح
const colorAnnouncement = Color(0xFF2196F3); // أزرق فاتح للإعلانات

// الألوان المتدرجة
const colorGradientPrimary = LinearGradient(
  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const colorGradientSecondary = LinearGradient(
  colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const colorGradientSuccess = LinearGradient(
  colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const colorGradientWarning = LinearGradient(
  colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const colorGradientAnnouncement = LinearGradient(
  colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// ألوان النص
const colorTextPrimary = Color(0xFF2D3748); // رمادي غامق للنصوص الرئيسية
const colorTextSecondary = Color(0xFF718096); // رمادي متوسط للنصوص الثانوية
const colorTextLight = Color(0xFFA0AEC0); // رمادي فاتح للنصوص الخفيفة

// ألوان الخلفية
const colorBackgroundLight = Color(0xFFF7FAFC); // خلفية فاتحة جداً
const colorBackgroundCard = Color(0xFFFFFFFF); // خلفية البطاقات
const colorBackgroundGradient = LinearGradient(
  colors: [Color(0xFFF8FAFF), Color(0xFFE6F3FF)],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

// ألوان الظلال
const colorShadowLight = Color(0x1A000000); // ظل خفيف
const colorShadowMedium = Color(0x33000000); // ظل متوسط

// الألوان القديمة (للتوافق)
const colorBlack12 = Colors.black12;
const colorSpecialBlue = Color(0XFF0d5aa4);
const colorSpecialLightBlue = Color(0XFF219EBC);
const colorSpecialPink = Color(0XFFcf376c);
const colorSpecialOrange = Color(0XFFf4942b);
const color1 = Color(0XFFA86346);
const color2 = Color(0XFF8F6D5C);
const color3 = Color(0XFFE9EBE8);
const color4 = Color(0XFFEBEDEA);
const color5 = Color(0XFFE7E9E6);

// الثوابت
const kTranstionDuration = Duration(milliseconds: 250);
const kGtSectraFine = '';

// أنماط النصوص
const textStyleHeading = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: colorTextPrimary,
  fontFamily: kGtSectraFine,
);

const textStyleSubheading = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  color: colorTextPrimary,
  fontFamily: kGtSectraFine,
);

const textStyleBody = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.normal,
  color: colorTextSecondary,
  fontFamily: kGtSectraFine,
);

const textStyleCaption = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.normal,
  color: colorTextLight,
  fontFamily: kGtSectraFine,
);

// Hugging Face configuration
// To use the Hugging Face Inference API, set `HUGGING_FACE_API_KEY` to your token.
// Leave empty to use the built-in offline rule-based fallback (free, no network needed).
const String HUGGING_FACE_API_KEY = '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';
const String HUGGING_FACE_MODEL = 'google/flan-t5-large';

// Cohere configuration
// You can store the Cohere API key here for quick testing or save it securely in app settings.
const String COHERE_API_KEY = 'fMJjeVzWd07LqQb5z4FpYIyuakPWZoSDCyH52GQF';
const String COHERE_MODEL = 'command-a-03-2025';
