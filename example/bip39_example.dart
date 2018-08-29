import 'package:bip39/bip39.dart';

main() async {
  String mnemonic = await generateMnemonic();
  print(mnemonicToSeedHex("update elbow source spin squeeze horror world become oak assist bomb nuclear"));
}
