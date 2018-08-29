import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:bip39/bip39.dart' as bip39;
import 'package:test/test.dart';

void main() {
  Map<String, dynamic> vectors =
  json.decode(File('./test/vectors.json').readAsStringSync(encoding: utf8));

  int i = 0;
  (vectors['english'] as List<dynamic>).forEach((list) {
    testVector(list, i);
    i++;
  });

  group('generateMnemonic', () {
    test('can vary entropy length', () async {
      final words = (await bip39.generateMnemonic(strength: 160)).split(' ');
      expect(words.length, equals(15),
          reason: 'can vary generated entropy bit length');
    });

    test('requests the exact amount of data from randomBytes function',
            () async {
          await bip39.generateMnemonic(
              strength: 160,
              randomBytes: (int size) {
                expect(size, 160 / 8);
                return Uint8List(size);
              });
        });
  });
}

void testVector(List<dynamic> v, int i) {
  final ventropy = v[0];
  final vmnemonic = v[1];
  final vseedHex = v[2];

  group('for Englist(${i}), ${ventropy}', () {
    setUp(() {});

//      test('mnemoic to entropy', () async {
//        final Uint8List entropy =
//        await bip39.mnemonicToEntropy(vmnemonic, wordlist);
//        expect(entropy, equals(HEX.decode(ventropy)));
//      });

    test('mnemonic to seed hex', () async {
      final seedHex = bip39.mnemonicToSeedHex(vmnemonic);
      expect(seedHex, equals(vseedHex));
    });

//      test('entropy to mnemonic', () async {
//        final entropy = HEX.decode(ventropy);
//
//        final code = await bip39.entropyToMnemonic(entropy, wordlist);
//        expect(code, equals(vmnemonic));
//
//        final code2 = await bip39.entropyHexToMnemonic(ventropy, wordlist);
//        expect(code2, equals(vmnemonic));
//      });
//
//      test('generate mnemonic', () async {
//        bip39.RandomBytes nextBytes = (int size) {
//          return HEX.decode(ventropy);
//        };
//        final code = await bip39.generateMnemonic(
//            randomBytes: nextBytes, wordlist: wordlist);
//        expect(code, equals(vmnemonic),
//            reason: 'generateMnemonic returns nextBytes entropy unmodified');
//      });
//
//      test('validate mnemonic', () async {
//        expect(await bip39.validateMnemonic(vmnemonic, wordlist), isTrue,
//            reason: 'validateMnemonic returns true');
//      });
  });
}
