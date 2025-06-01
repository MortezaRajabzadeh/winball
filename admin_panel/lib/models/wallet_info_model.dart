class WalletInfo {
  final String seedPhrase;
  final String walletAddress;

  WalletInfo({
    required this.seedPhrase,
    required this.walletAddress,
  });

  Map<String, dynamic> toJson() {
    return {
      'seedPhrase': seedPhrase,
      'walletAddress': walletAddress,
    };
  }

  factory WalletInfo.fromJson(Map<String, dynamic> json) {
    return WalletInfo(
      seedPhrase: json['seedPhrase'] as String,
      walletAddress: json['walletAddress'] as String,
    );
  }
} 