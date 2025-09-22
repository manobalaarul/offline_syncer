import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';

class EncryptionService {
  final FlutterSecureStorage secureStorage;
  static const _aesKeyStorageKey = 'offline_sync_aes_key';
  static const _hmacKeyStorageKey = 'offline_sync_hmac_key';

  EncryptionService(this.secureStorage);

  Future<Uint8List> _getAesKey() async {
    var key = await secureStorage.read(key: _aesKeyStorageKey);
    if (key == null) {
      final bytes = List<int>.generate(32, (_) => Random.secure().nextInt(256));
      await secureStorage.write(key: _aesKeyStorageKey, value: base64Encode(bytes));
      return Uint8List.fromList(bytes);
    }
    return base64Decode(key);
  }

  Future<String> encryptJson(Map<String, dynamic> json) async {
    final keyBytes = await _getAesKey();
    final key = Key(keyBytes);
    final iv = IV.fromSecureRandom(16);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final plaintext = utf8.encode(jsonEncode(json));
    final cipher = encrypter.encryptBytes(plaintext, iv: iv);
    final combined = iv.bytes + cipher.bytes; // store IV + ciphertext
    return base64Encode(combined);
  }

  Future<Map<String, dynamic>> decryptBase64(String b64) async {
    final keyBytes = await _getAesKey();
    final bytes = base64Decode(b64);
    final iv = IV(bytes.sublist(0, 16));
    final ciphertext = Encrypted(bytes.sublist(16));
    final encrypter = Encrypter(AES(Key(keyBytes), mode: AESMode.cbc));
    final dec = encrypter.decryptBytes(ciphertext, iv: iv);
    return jsonDecode(utf8.decode(dec)) as Map<String, dynamic>;
  }

  /// HMAC signature
  Future<String> sign(String appId, String endpoint, String payloadB64, int timestamp) async {
    String secret = await _getOrCreateHmacSecret();
    final key = utf8.encode(secret);
    final msg = utf8.encode('$appId|$endpoint|$timestamp|$payloadB64');
    final hmac = Hmac(sha256, key);
    return base64Encode(hmac.convert(msg).bytes);
  }

  Future<String> _getOrCreateHmacSecret() async {
    var val = await secureStorage.read(key: _hmacKeyStorageKey);
    if (val == null) {
      final keyBytes = List<int>.generate(32, (_) => Random.secure().nextInt(256));
      val = base64Encode(keyBytes);
      await secureStorage.write(key: _hmacKeyStorageKey, value: val);
    }
    return val;
  }
}
