import 'package:bip39/bip39.dart' as bip39;

void main() async {
  var randomMnemonic = bip39.generateMnemonic();
  print(randomMnemonic);
  var seed = bip39.mnemonicToSeedHex('update elbow source spin squeeze horror world become oak assist bomb nuclear');
  print(seed);
  var mnemonic = bip39.entropyToMnemonic('00000000000000000000000000000000');
  print(mnemonic);
  var isValid = bip39.validateMnemonic(mnemonic);
  print(isValid);
  isValid = bip39.validateMnemonic('basket actual');
  print(isValid);
  var entropy = bip39.mnemonicToEntropy(mnemonic);
  print(entropy);
}
