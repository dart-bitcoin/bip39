import 'package:bip39/bip39.dart' as bip39;
import 'dart:typed_data';
import 'package:test/test.dart';

void main() {
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
