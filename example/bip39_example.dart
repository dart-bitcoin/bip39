import 'package:bip39/bip39.dart' as bip39;

main() async {
  String randomMnemonic = bip39.generateMnemonic();
  print(randomMnemonic);
  String seed = bip39.mnemonicToSeedHex("update elbow source spin squeeze horror world become oak assist bomb nuclear");
  print(seed);
  String mnemonic = bip39.entropyToMnemonic('00000000000000000000000000000000');
  print(mnemonic);
  bool isValid = bip39.validateMnemonic(mnemonic);
  print(isValid);
  isValid = bip39.validateMnemonic('basket actual');
  print(isValid);
  String entropy = bip39.mnemonicToEntropy(mnemonic);
  print(entropy);
}
