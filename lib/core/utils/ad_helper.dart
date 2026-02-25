import 'dart:io';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      // ID Banner Test Android dari Google
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      // ID Banner Test iOS dari Google
      return 'ca-app-pub-3940256099942544/2934735716';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
