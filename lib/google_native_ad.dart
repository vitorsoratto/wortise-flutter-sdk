import 'dart:async';

import 'package:flutter/services.dart';

import 'base_ad.dart';
import 'wortise_sdk.dart';

enum GoogleNativeAdEvent {
  CLICKED,
  FAILED,
  IMPRESSION,
  LOADED
}

class GoogleNativeAd extends BaseAd {

  static const CHANNEL_NATIVE = "${WortiseSdk.CHANNEL_MAIN}/nativeAd";

  static const MethodChannel _channel = const MethodChannel(CHANNEL_NATIVE);


  MethodChannel? _adChannel;

  final String factoryId;

  final void Function(GoogleNativeAdEvent, dynamic)? listener;


  GoogleNativeAd(String adUnitId, this.factoryId, this.listener) : super(adUnitId: adUnitId) {    
    if (listener != null) {
      _adChannel = MethodChannel('${CHANNEL_NATIVE}_$adId');
      _adChannel?.setMethodCallHandler(_handleEvent);
    }
  }

  Future<void> destroy() async {
    Map<String, dynamic> values = {
      'adId': adId
    };

    await _channel.invokeMethod('destroy', values);
  }

  Future<void> load() async {
    Map<String, dynamic> values = {
      'adId':      adId,
      'adUnitId':  adUnitId,
      'factoryId': factoryId
    };

    await _channel.invokeMethod('load', values);
  }


  Future<dynamic> _handleEvent(MethodCall call) {
    switch (call.method) {
    case "clicked":
      listener?.call(GoogleNativeAdEvent.CLICKED, call.arguments);
      break;

    case "failed":
      listener?.call(GoogleNativeAdEvent.FAILED, call.arguments);
      break;

    case "impression":
      listener?.call(GoogleNativeAdEvent.IMPRESSION, call.arguments);
      break;

    case "loaded":
      listener?.call(GoogleNativeAdEvent.LOADED, call.arguments);
      break;
    }

    return Future.value(true);
  }
}
