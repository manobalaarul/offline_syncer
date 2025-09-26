import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

class EncryptionHelper {
  static final EncryptionHelper _instance = EncryptionHelper._internal();
  factory EncryptionHelper() => _instance;
  EncryptionHelper._internal();

  Encrypter? _encrypter;
  IV? _iv;

  void initialize(String encryptionKey) {
    // Create a 256-bit key from the provided key
    final bytes = utf8.encode(encryptionKey);
    final digest = sha256.convert(bytes);
    final key = Key(Uint8List.fromList(digest.bytes));
    
    _encrypter = Encrypter(AES(key));
    _iv = IV.fromSecureRandom(16);
  }

  String encrypt(Map<String, dynamic> data) {
    if (_encrypter == null) {
      throw StateError('EncryptionHelper not initialized');
    }
    
    final jsonString = jsonEncode(data);
    final encrypted = _encrypter!.encrypt(jsonString, iv: _iv!);
    
    // Combine IV and encrypted data for storage
    final combined = _iv!.bytes + encrypted.bytes;
    return base64Encode(combined);
  }

  Map<String, dynamic> decrypt(String encryptedData) {
    if (_encrypter == null) {
      throw StateError('EncryptionHelper not initialized');
    }
    
    final combined = base64Decode(encryptedData);
    
    // Extract IV and encrypted data
    final iv = IV(Uint8List.fromList(combined.take(16).toList()));
    final encryptedBytes = combined.skip(16).toList();
    
    final encrypted = Encrypted(Uint8List.fromList(encryptedBytes));
    final decrypted = _encrypter!.decrypt(encrypted, iv: iv);
    
    return jsonDecode(decrypted);
  }
}