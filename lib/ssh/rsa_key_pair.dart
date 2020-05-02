import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:gitjournal/ssh/binary_length_value.dart';
import 'package:steel_crypt/PointyCastleN/key_generators/rsa_key_generator.dart';
import 'package:steel_crypt/PointyCastleN/pointycastle.dart';
import 'package:steel_crypt/PointyCastleN/random/fortuna_random.dart';
import 'package:steel_crypt/steel_crypt.dart';

class RsaKeyPair {
  RSAPublicKey publicKey;
  RSAPrivateKey privateKey;

  RsaKeyPair.fromFiles(priv, pub);
  RsaKeyPair.fromStrings(priv, pub);

  RsaKeyPair.generate() {
    var keyPair = _getRsaKeyPair(_getSecureRandom());
    publicKey = keyPair.publicKey as RSAPublicKey;
    privateKey = keyPair.privateKey as RSAPrivateKey;
  }

  // Tries to encrypt and decrypt
  bool isValid() {
    var encrypter = RsaCrypt();
    var orig = 'word';
    var enc = encrypter.encrypt(orig, publicKey);
    var dec = encrypter.decrypt(enc, privateKey);

    return orig == dec;
  }

  // OpenSSH Public Key (single-line format)
  String publicKeyString({String comment = ""}) {
    var data = BinaryLengthValue.encode([
      BinaryLengthValue.fromString("ssh-rsa"),
      BinaryLengthValue.fromBigInt(publicKey.exponent),
      BinaryLengthValue.fromBigInt(publicKey.modulus),
    ]);

    if (comment.isNotEmpty) {
      comment = comment.replaceAll('\r', ' ');
      comment = comment.replaceAll('\n', ' ');
      comment = ' $comment';
    }

    return 'ssh-rsa ${base64.encode(data)}$comment';
  }

  String privateKeyString() {
    var encrypter = RsaCrypt();
    return encrypter.encodeKeyToString(privateKey);
  }
}

SecureRandom _getSecureRandom() {
  final secureRandom = FortunaRandom();
  final random = Random.secure();
  var seeds = List<int>.of([]);
  for (var i = 0; i < 32; i++) {
    seeds.add(random.nextInt(255));
  }
  secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));
  return secureRandom;
}

///Create RSA keypair given SecureRandom.
AsymmetricKeyPair<PublicKey, PrivateKey> _getRsaKeyPair(
  SecureRandom secureRandom,
) {
  // See URL for why these values
  // https://crypto.stackexchange.com/questions/15449/rsa-key-generation-parameters-public-exponent-certainty-string-to-key-count/15450#15450?newreg=e734eafab61e42f1b155b62839ccce8f
  final rsapars = RSAKeyGeneratorParameters(BigInt.from(65537), 2048 * 2, 5);
  final params = ParametersWithRandom(rsapars, secureRandom);
  final keyGenerator = RSAKeyGenerator();
  keyGenerator.init(params);
  return keyGenerator.generateKeyPair();
}
