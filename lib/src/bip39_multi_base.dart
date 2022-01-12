import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart' show sha256;
import 'package:hex/hex.dart';
import 'utils/pbkdf2.dart';
import 'wordlists/all.dart';

const String _defaultLanguage="english";
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
String generateMnemonic({
  int strength = 128,
  RandomBytes randomBytes = _randomBytes,
  String language=_defaultLanguage
}) {
  assert(strength % 32 == 0);
  final entropy = randomBytes(strength ~/ 8);
  return entropyToMnemonic(HEX.encode(entropy),language: language);
}
String entropyToMnemonic(String entropyString,{String language=_defaultLanguage}) {
  final entropy = HEX.decode(entropyString);
  if (entropy.length < 4) {
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
  print("***************");
  print(language);
  List<String> wordlist = WORDLIST[language];
  String words = chunks.map((binary) => wordlist[_binaryToByte(binary)]).join(' ');
  return words;
}
Uint8List mnemonicToSeed(String mnemonic) {
  final pbkdf2 = new PBKDF2();
  return pbkdf2.process(mnemonic);
}
String mnemonicToSeedHex(String mnemonic) {
  return mnemonicToSeed(mnemonic).map((byte) {
    return byte.toRadixString(16).padLeft(2, '0');
  }).join('');
}
bool validateMnemonic(String mnemonic,{String language=_defaultLanguage}) {
  try {
    mnemonicToEntropy(mnemonic,language: language);
  } catch (e) {
    return false;
  }
  return true;
}
String mnemonicToEntropy (mnemonic,{String language=_defaultLanguage}) {
  var words = mnemonic.split(' ');
  if (words.length % 3 != 0) {
    throw new ArgumentError(_INVALID_MNEMONIC);
  }
  final wordlist = WORDLIST[language];
    // convert word indices to 11 bit binary strings
    final bits = words.map((word) {
      final index = wordlist.indexOf(word);
      if (index == -1) {
        throw new ArgumentError(_INVALID_MNEMONIC);
      }
      return index.toRadixString(2).padLeft(11, '0');
    }).join('');
  // split the binary string into ENT/CS
  final dividerIndex = (bits.length / 33).floor() * 32;
  final entropyBits = bits.substring(0, dividerIndex);
  final checksumBits = bits.substring(dividerIndex);

    // calculate the checksum and compare
  final regex = RegExp(r".{1,8}");
  final entropyBytes = Uint8List.fromList(regex
      .allMatches(entropyBits)
      .map((match) => _binaryToByte(match.group(0)))
      .toList(growable: false));
  if (entropyBytes.length < 4) {
    throw StateError(_INVALID_ENTROPY);
  }
  if (entropyBytes.length > 32) {
    throw StateError(_INVALID_ENTROPY);
  }
  if (entropyBytes.length % 4 != 0) {
    throw StateError(_INVALID_ENTROPY);
  }
  final newChecksum = _deriveChecksumBits(entropyBytes);
  if (newChecksum != checksumBits) {
    throw StateError(_INVALID_CHECKSUM);
  }
  return entropyBytes.map((byte) {
    return byte.toRadixString(16).padLeft(2, '0');
  }).join('');
}
// List<String>> _loadWordList() {
//   final res = new Resource('package:bip39/src/wordlists/english.json').readAsString();
//   List<String> words = (json.decode(res) as List).map((e) => e.toString()).toList();
//   return words;
// }
