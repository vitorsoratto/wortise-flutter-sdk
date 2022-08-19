abstract class BaseAd {

  static int _currentId = 1;


  final String adId = (_currentId++).toString();

  final String adUnitId;


  BaseAd({required this.adUnitId});
}