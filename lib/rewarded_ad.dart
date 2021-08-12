import 'dart:async';

import 'package:flutter/services.dart';

import 'wortise_sdk.dart';

enum RewardedAdEvent {
  CLICKED,
  COMPLETED,
  DISMISSED,
  FAILED,
  LOADED,
  SHOWN,
}

class RewardedAd {

  static const CHANNEL_REWARDED = "${WortiseSdk.CHANNEL_MAIN}/rewardedAd";

  static const MethodChannel _channel = const MethodChannel(CHANNEL_REWARDED);


  MethodChannel _adChannel;

  final String adUnitId;

  final void Function(RewardedAdEvent, dynamic) listener;

  final bool reloadOnDismissed;


  RewardedAd(this.adUnitId, this.listener, {this.reloadOnDismissed = false}) {
    if (listener != null) {
      _adChannel = MethodChannel('${CHANNEL_REWARDED}_$adUnitId');
      _adChannel.setMethodCallHandler(_handleEvent);
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

    await _channel.invokeMethod('showAd', values);
  }


  Future<dynamic> _handleEvent(MethodCall call) {
    switch (call.method) {
    case "clicked":
      listener(RewardedAdEvent.CLICKED, call.arguments);
      break;

    case "completed":
      listener(RewardedAdEvent.COMPLETED, call.arguments);
      break;

    case "dismissed":
      listener(RewardedAdEvent.DISMISSED, call.arguments);

      if (reloadOnDismissed) {
        loadAd();
      }

      break;

    case "failed":
      listener(RewardedAdEvent.FAILED, call.arguments);
      break;

    case "loaded":
      listener(RewardedAdEvent.LOADED, call.arguments);
      break;

    case "shown":
      listener(RewardedAdEvent.SHOWN, call.arguments);
      break;
    }

    return Future.value(true);
  }
}
