import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:resource/resource.dart' show Resource;
import 'utils/pbkdf2.dart';

const int _SIZE_BYTE = 255;
const _INVALID_MNEMONIC = 'Invalid mnemonic';
const _INVALID_ENTROPY = 'Invalid entropy';
const _INVALID_CHECKSUM = 'Invalid mnemonic checksum';

typedef Uint8List RandomBytes(int size);

int _binaryToByte(String binary) {
  return int.parse(binary, radix: 2);
}

String _bytesToBinary(Uint8List bytes) {
  return bytes.map((byte) => byte.toRadixString(2).padLeft(8, '0')).join('');
}


//Uint8List _createUint8ListFromString( String s ) {
//  var ret = new Uint8List(s.length);
//  for( var i=0 ; i<s.length ; i++ ) {
//    ret[i] = s.codeUnitAt(i);
//  }
//  return ret;
//}


String _deriveChecksumBits(Uint8List entropy) {
  final ENT = entropy.length * 8;
  final CS = ENT ~/ 32;
  final hash = sha256.newInstance().convert(entropy);
  return _bytesToBinary(Uint8List.fromList(hash.bytes)).substring(0, CS);
}


Uint8List _randomBytes(int size) {
  final rng = Random.secure();
  final bytes = Uint8List(size);
  for (var i = 0; i < size; i++) {
    bytes[i] = rng.nextInt(_SIZE_BYTE);
  }
  return bytes;
}
Future<String> generateMnemonic({
  int strength = 128,
  RandomBytes randomBytes = _randomBytes
}) async {
  assert(strength % 32 == 0);
  final entropy = randomBytes(strength ~/ 8);
  return await entropyToMnemonic(entropy);
}
Future<String> entropyToMnemonic(Uint8List entropy) async {
  if (entropy.length < 16) {
    throw ArgumentError(_INVALID_ENTROPY);
  }
  if (entropy.length > 32) {
    throw ArgumentError(_INVALID_ENTROPY);
  }
  if (entropy.length % 4 != 0) {
    throw ArgumentError(_INVALID_ENTROPY);
  }
  final entropyBits = _bytesToBinary(entropy);
  final checksumBits = _deriveChecksumBits(entropy);
  final bits = entropyBits + checksumBits;
  final regex = new RegExp(r".{1,11}", caseSensitive: false, multiLine: false);
  final chunks = regex
      .allMatches(bits)
      .map((match) => match.group(0))
      .toList(growable: false);
  List<String> wordlist = await _loadWordList();
  String words = chunks.map((binary) => wordlist[_binaryToByte(binary)]).join(' ');
  return words;
}
Uint8List mnemonicToSeed(String mnemonic) {
//  final mnemonicBuffer = utf8.encode(mnemonic);
//  final saltBuffer = utf8.encode("mnemonic");
  final pbkdf2 = new PBKDF2(salt: "mnemonic");
  return pbkdf2.process(mnemonic);
}
String mnemonicToSeedHex(String mnemonic) {
  return mnemonicToSeed(mnemonic).map((byte) {
    return byte.toRadixString(16).padLeft(2, '0');
  }).join('');
}

Future<List<String>> _loadWordList() async {
  final res = await new Resource('package:bip39/src/wordlists/english.json').readAsString();
  List<String> words = (json.decode(res) as List).map((e) => e.toString()).toList();
  return words;
}
