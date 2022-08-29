import 'dart:async';

import 'package:flutter/services.dart';

import 'wortise_sdk.dart';

enum AppOpenAdEvent {
  CLICKED,
  DISMISSED,
  FAILED,
  LOADED,
  SHOWN,
}

enum AppOpenOrientation {
  LANDSCAPE,
  PORTRAIT
}

class AppOpenAd {

  static const CHANNEL_APP_OPEN = "${WortiseSdk.CHANNEL_MAIN}/appOpenAd";

  static const MethodChannel _channel = const MethodChannel(CHANNEL_APP_OPEN);


  MethodChannel? _adChannel;

  final String adUnitId;

  final bool autoReload;

  final void Function(AppOpenAdEvent, dynamic)? listener;

  final AppOpenOrientation orientation;


  AppOpenAd(this.adUnitId, {this.listener, this.autoReload = false, this.orientation = AppOpenOrientation.PORTRAIT}) {
    if (listener != null) {
      _adChannel = MethodChannel('${CHANNEL_APP_OPEN}_$adUnitId');
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

  Future<bool> get isShowing async {
    Map<String, dynamic> values = {
      'adUnitId': adUnitId
    };

    return await _channel.invokeMethod('isShowing', values);
  }

  Future<void> destroy() async {
    Map<String, dynamic> values = {
      'adUnitId': adUnitId
    };

    await _channel.invokeMethod('destroy', values);
  }

  Future<void> loadAd() async {
    Map<String, dynamic> values = {
      'adUnitId': adUnitId,
      'autoReload': autoReload,
      'orientation': orientation.name
    };

    await _channel.invokeMethod('loadAd', values);
  }

  Future<bool> showAd() async {
    Map<String, dynamic> values = {
      'adUnitId': adUnitId
    };

    return await _channel.invokeMethod('showAd', values);
  }

  Future<bool> tryToShowAd() async {
    Map<String, dynamic> values = {
      'adUnitId': adUnitId
    };

    return await _channel.invokeMethod('tryToShowAd', values);
  }


  Future<dynamic> _handleEvent(MethodCall call) {
    switch (call.method) {
    case "clicked":
      listener?.call(AppOpenAdEvent.CLICKED, call.arguments);
      break;

    case "dismissed":
      listener?.call(AppOpenAdEvent.DISMISSED, call.arguments);
      break;

    case "failed":
      listener?.call(AppOpenAdEvent.FAILED, call.arguments);
      break;

    case "loaded":
      listener?.call(AppOpenAdEvent.LOADED, call.arguments);
      break;

    case "shown":
      listener?.call(AppOpenAdEvent.SHOWN, call.arguments);
      break;
    }

    return Future.value(true);
  }
}
