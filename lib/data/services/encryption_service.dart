import 'package:encrypt/encrypt.dart' as enc;

class EncryptionService {
  // 1. Fetch from Environment (passed via Makefile)
  // Fallback provided just in case dev env is missing keys.
  static const _envPassword = String.fromEnvironment(
    'UFT_PASSWORD', 
    defaultValue: 'FeesUpDefaultDevKey32CharsLong!!' 
  );

  // 2. Ensure Key is exactly 32 chars for AES-256
  static final _keyString = _envPassword.padRight(32, '#').substring(0, 32);

  static final _key = enc.Key.fromUtf8(_keyString);
  static final _iv = enc.IV.fromLength(16);
  static final _encrypter = enc.Encrypter(enc.AES(_key));

  static String encrypt(String plainText) {
    return _encrypter.encrypt(plainText, iv: _iv).base64;
  }

  static String decrypt(String encryptedBase64) {
    try {
      return _encrypter.decrypt(enc.Encrypted.fromBase64(encryptedBase64), iv: _iv);
    } catch (e) {
      return "[]";
    }
  }
}