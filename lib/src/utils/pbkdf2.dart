import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/digests/sha512.dart';
import 'package:pointycastle/key_derivators/api.dart' show Pbkdf2Parameters;
import 'package:pointycastle/key_derivators/pbkdf2.dart';
import 'package:pointycastle/macs/hmac.dart';

class PBKDF2 {
  final int blockLength;
  final int iterationCount;
  final int desiredKeyLength;
  final String saltPrefix = "mnemonic";

  PBKDF2KeyDerivator _derivator;

  PBKDF2({this.blockLength = 128,
          this.iterationCount = 2048,
          this.desiredKeyLength = 64,
          }) {
    _derivator =
    new PBKDF2KeyDerivator(new HMac(new SHA512Digest(), blockLength)) ;
  }

  Uint8List process(String mnemonic, {passphrase: ""}) {
      Uint8List salt = utf8.encode(saltPrefix + passphrase);
      _derivator.reset();
      _derivator.init(new Pbkdf2Parameters(salt, iterationCount,
                      desiredKeyLength));
    return _derivator.process(new Uint8List.fromList(mnemonic.codeUnits));
  }
}
