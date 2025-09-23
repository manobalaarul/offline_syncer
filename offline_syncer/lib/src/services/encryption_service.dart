import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionService {
  final FlutterSecureStorage _secureStorage;
  static const _aesKeyStorageKey = 'offline_sync_aes_key';
  static const _hmacKeyStorageKey = 'offline_sync_hmac_key';

  EncryptionService(this._secureStorage);

  Future<String> encryptData(Map<String, dynamic> data) async {
    if (data.isEmpty) return '';

    try {
      final keyBytes = await _getAesKey();
      final key = Key(keyBytes);
      final iv = IV.fromSecureRandom(16);
      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
      final plaintext = utf8.encode(jsonEncode(data));
      final cipher = encrypter.encryptBytes(plaintext, iv: iv);
      final combined = iv.bytes + cipher.bytes;
      return base64Encode(combined);
    } catch (e) {
      throw Exception('Encryption failed: $e');
    }
  }

  Future<Map<String, dynamic>> decryptData(String encryptedData) async {
    if (encryptedData.isEmpty) return {};

    try {
      final keyBytes = await _getAesKey();
      final bytes = base64Decode(encryptedData);
      final iv = IV(bytes.sublist(0, 16));
      final ciphertext = Encrypted(bytes.sublist(16));
      final encrypter = Encrypter(AES(Key(keyBytes), mode: AESMode.cbc));
      final decryptedBytes = encrypter.decryptBytes(ciphertext, iv: iv);
      return jsonDecode(utf8.decode(decryptedBytes)) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }

  Future<String> generateSignature({
    required String appId,
    required String endpoint,
    required String payload,
    required int timestamp,
  }) async {
    try {
      final secret = await _getHmacSecret();
      final key = utf8.encode(secret);
      final message = utf8.encode('$appId|$endpoint|$timestamp|$payload');
      final hmac = Hmac(sha256, key);
      return base64Encode(hmac.convert(message).bytes);
    } catch (e) {
      throw Exception('Signature generation failed: $e');
    }
  }

  Future<Uint8List> _getAesKey() async {
    final key = await _secureStorage.read(key: _aesKeyStorageKey);
    if (key == null) {
      final bytes = List<int>.generate(32, (_) => Random.secure().nextInt(256));
      await _secureStorage.write(
        key: _aesKeyStorageKey,
        value: base64Encode(bytes),
      );
      return Uint8List.fromList(bytes);
    }
    return base64Decode(key);
  }

  Future<String> _getHmacSecret() async {
    var secret = await _secureStorage.read(key: _hmacKeyStorageKey);
    if (secret == null) {
      final keyBytes = List<int>.generate(
        32,
        (_) => Random.secure().nextInt(256),
      );
      secret = base64Encode(keyBytes);
      await _secureStorage.write(key: _hmacKeyStorageKey, value: secret);
    }
    return secret;
  }
}
