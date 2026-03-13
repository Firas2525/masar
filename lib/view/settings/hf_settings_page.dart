import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../color.dart';
import '../../services/secure_storage_service.dart';
import '../../constants.dart';

class HfSettingsPage extends StatefulWidget {
  const HfSettingsPage({Key? key}) : super(key: key);

  @override
  State<HfSettingsPage> createState() => _HfSettingsPageState();
}

class _HfSettingsPageState extends State<HfSettingsPage> {
  final TextEditingController _ctrl = TextEditingController();
  final TextEditingController _coCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final v = await SecureStorageService.getHfApiKey();
    if (v.isEmpty && HUGGING_FACE_API_KEY.trim().isNotEmpty) {
      _ctrl.text = HUGGING_FACE_API_KEY;
    } else {
      _ctrl.text = v;
    }

    final c = await SecureStorageService.getCohereApiKey();
    if (c.isEmpty && COHERE_API_KEY.trim().isNotEmpty) {
      _coCtrl.text = COHERE_API_KEY;
    } else {
      _coCtrl.text = c;
    }

    setState(() {});
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await SecureStorageService.setHfApiKey(_ctrl.text.trim());
    await SecureStorageService.setCohereApiKey(_coCtrl.text.trim());
    setState(() => _saving = false);
    Get.snackbar('تم', 'تم حفظ المفاتيح بنجاح');
  }

  Future<void> _clear() async {
    await SecureStorageService.deleteHfApiKey();
    await SecureStorageService.deleteCohereApiKey();
    _ctrl.clear();
    _coCtrl.clear();
    Get.snackbar('تم', 'تم حذف المفاتيح');
    setState(() {});
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _coCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('إعداد Hugging Face'), backgroundColor: primaryblue),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('يمكنك إدخال مفتاح Hugging Face أو Cohere. إبقاء الحقول فارغة يفعّل الإجابات المحلية (مجانية).', style: textStyleBody),
            SizedBox(height: 12),

            // Hugging Face field
            TextField(
              controller: _ctrl,
              decoration: InputDecoration(labelText: 'مفتاح Hugging Face (اختياري)', border: OutlineInputBorder()),
            ),
            SizedBox(height: 12),

            // Cohere field
            TextField(
              controller: _coCtrl,
              decoration: InputDecoration(labelText: 'مفتاح Cohere (اختياري)', border: OutlineInputBorder()),
            ),

            SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(onPressed: _saving ? null : _save, child: _saving ? CircularProgressIndicator() : Text('حفظ')),
                SizedBox(width: 12),
                OutlinedButton(onPressed: _clear, child: Text('حذف')),
              ],
            ),
            SizedBox(height: 12),
            Text('تنبيه: لا تُشارك مفتاحك في مكان عام. إذا قمت بمشاركته مسبقاً، قم بتدويره (Regenerate).', style: textStyleCaption),
          ],
        ),
      ),
    );
  }
}
