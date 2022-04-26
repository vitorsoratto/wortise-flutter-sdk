import 'dart:async';

import 'package:flutter/services.dart';

import 'wortise_sdk.dart';

enum InterstitialAdEvent {
  CLICKED,
  DISMISSED,
  FAILED,
  LOADED,
  SHOWN,
}

class InterstitialAd {

  static const CHANNEL_INTERSTITIAL = "${WortiseSdk.CHANNEL_MAIN}/interstitialAd";

  static const MethodChannel _channel = const MethodChannel(CHANNEL_INTERSTITIAL);


  MethodChannel? _adChannel;

  final String adUnitId;

  final void Function(InterstitialAdEvent, dynamic)? listener;

  final bool reloadOnDismissed;


  InterstitialAd(this.adUnitId, this.listener, {this.reloadOnDismissed = false}) {
    if (listener != null) {
      _adChannel = MethodChannel('${CHANNEL_INTERSTITIAL}_$adUnitId');
      _adChannel?.setMethodCallHandler(_handleEvent);
    }
  }

  Future<bool> get isAvailable async {
    Map<String, dynamic> values = {
      'adUnitId': adUnitId
    };

    return await _channel.invokeMethod('isAvailable', values);
  }

  Future<bool> get isDestroyed async {
    Map<String, dynamic> values = {
      'adUnitId': adUnitId
    };

    return await _channel.invokeMethod('isDestroyed', values);
  }

  Future<void> destroy() async {
    Map<String, dynamic> values = {
      'adUnitId': adUnitId
    };

    await _channel.invokeMethod('destroy', values);
  }

  Future<void> loadAd() async {
    Map<String, dynamic> values = {
      'adUnitId': adUnitId
    };

    await _channel.invokeMethod('loadAd', values);
  }

  Future<bool> showAd() async {
    Map<String, dynamic> values = {
      'adUnitId': adUnitId
    };

    return await _channel.invokeMethod('showAd', values);
  }


  Future<dynamic> _handleEvent(MethodCall call) {
    switch (call.method) {
    case "clicked":
      listener?.call(InterstitialAdEvent.CLICKED, call.arguments);
      break;

    case "dismissed":
      listener?.call(InterstitialAdEvent.DISMISSED, call.arguments);

      if (reloadOnDismissed) {
        loadAd();
      }

      break;

    case "failed":
      listener?.call(InterstitialAdEvent.FAILED, call.arguments);
      break;

    case "loaded":
      listener?.call(InterstitialAdEvent.LOADED, call.arguments);
      break;

    case "shown":
      listener?.call(InterstitialAdEvent.SHOWN, call.arguments);
      break;
    }

    return Future.value(true);
  }
}
