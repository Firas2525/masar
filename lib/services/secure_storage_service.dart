import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants.dart';

class SecureStorageService {
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _hfKey = 'HUGGING_FACE_API_KEY';
  static const String _cohereKey = 'COHERE_API_KEY';

  static Future<void> setHfApiKey(String key) async {
    await _storage.write(key: _hfKey, value: key);
  }

  static Future<String> getHfApiKey() async {
    final v = await _storage.read(key: _hfKey);
    return v ?? '';
  }

  static Future<void> deleteHfApiKey() async {
    await _storage.delete(key: _hfKey);
  }

  static Future<void> setCohereApiKey(String key) async {
    await _storage.write(key: _cohereKey, value: key);
  }

  static Future<String> getCohereApiKey() async {
    final v = await _storage.read(key: _cohereKey);
    return v ?? '';
  }

  static Future<void> deleteCohereApiKey() async {
    await _storage.delete(key: _cohereKey);
  }

  /// Ensure any key provided in constants is copied to secure storage if storage is empty.
  static Future<void> ensureKeysFromConstants() async {
    try {
      final currentHf = await getHfApiKey();
      if ((currentHf).trim().isEmpty && HUGGING_FACE_API_KEY.trim().isNotEmpty) {
        await setHfApiKey(HUGGING_FACE_API_KEY);
      }

      final currentCoh = await getCohereApiKey();
      if ((currentCoh).trim().isEmpty && COHERE_API_KEY.trim().isNotEmpty) {
        await setCohereApiKey(COHERE_API_KEY);
      }
    } catch (e) {
      // ignore errors here; callers will handle fallbacks
    }
  }
}
