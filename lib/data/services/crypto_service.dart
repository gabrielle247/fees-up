import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

class CryptoService {
  static final Pbkdf2 _pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac(Sha256()),
    iterations: 100000,
    bits: 256,
  );

  static final AesGcm _aesGcm = AesGcm.with256bits();

  /// Derive a 256-bit key from `email` and `uid` using PBKDF2-HMAC-SHA256.
  /// This is pure Dart and cross-platform.
  static Future<SecretKey> deriveUserKey({
    required String email,
    required String uid,
    List<int>? salt,
  }) async {
    final passwordBytes = utf8.encode('$email::$uid');
    final usedSalt = salt ?? utf8.encode('feesup-pepper-v1');
    return _pbkdf2.deriveKey(
      secretKey: SecretKey(passwordBytes),
      nonce: usedSalt,
    );
  }

  /// Encrypt a UTF-8 string with AES-GCM and return base64url.
  static Future<String> encryptString(String plaintext, SecretKey key) async {
    final nonce = _randomBytes(12); // 96-bit nonce for GCM
    final secretBox = await _aesGcm.encrypt(
      utf8.encode(plaintext),
      secretKey: key,
      nonce: nonce,
    );
    final combined = Uint8List.fromList([
      ...nonce,
      ...secretBox.cipherText,
      ...secretBox.mac.bytes,
    ]);
    return base64UrlEncode(combined);
  }

  /// Decrypt a base64url string previously produced by [encryptString].
  static Future<String> decryptString(String data, SecretKey key) async {
    final raw = base64Url.decode(data);
    if (raw.length < 12 + 16) {
      throw ArgumentError('Invalid encrypted payload');
    }
    final nonce = raw.sublist(0, 12);
    final mac = Mac(raw.sublist(raw.length - 16));
    final cipherText = raw.sublist(12, raw.length - 16);
    final decrypted = await _aesGcm.decrypt(
      SecretBox(cipherText, nonce: nonce, mac: mac),
      secretKey: key,
    );
    return utf8.decode(decrypted);
  }

  static List<int> _randomBytes(int length) {
    final rnd = Random.secure();
    return List<int>.generate(length, (_) => rnd.nextInt(256));
  }
}
