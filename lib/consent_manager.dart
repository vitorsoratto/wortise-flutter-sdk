import 'dart:async';

import 'package:flutter/services.dart';

import 'wortise_sdk.dart';

class ConsentManager {

  static const CHANNEL_CONSENT = "${WortiseSdk.CHANNEL_MAIN}/consentManager";

  static const MethodChannel _channel = const MethodChannel(CHANNEL_CONSENT);


  static Future<bool> get canCollectData async {
    return await _channel.invokeMethod('canCollectData');
  }

  static Future<bool> get isGranted async {
    return await _channel.invokeMethod('isGranted');
  }

  static Future<bool> get isReplied async {
    return await _channel.invokeMethod('isReplied');
  }

  static Future<bool> request({bool withOptOut = false}) async {
    Map<String, dynamic> values = {
      'withOptOut': withOptOut
    };

    await _channel.invokeMethod('request', values);
  }

  static Future<bool> requestOnce({bool withOptOut = false}) async {
    Map<String, dynamic> values = {
      'withOptOut': withOptOut
    };

    await _channel.invokeMethod('requestOnce', values);
  }

  static Future<void> set(bool granted) async {
    Map<String, dynamic> values = {
      'granted': granted
    };

    await _channel.invokeMethod('set', values);
  }

  static Future<void> setIabString(String value) async {
    Map<String, dynamic> values = {
      'value': value
    };

    await _channel.invokeMethod('setIabString', values);
  }
}
