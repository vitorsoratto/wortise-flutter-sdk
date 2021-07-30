import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'ad_size.dart';
import 'wortise_sdk.dart';

enum BannerAdEvent {
  CLICKED,
  FAILED,
  LOADED,
}

class BannerAd extends StatefulWidget {

  static const CHANNEL_BANNER = "${WortiseSdk.CHANNEL_MAIN}/bannerAd";


  final AdSize adSize;

  final String adUnitId;

  final int autoRefreshTime;

  final bool keepAlive;

  final void Function(BannerAdEvent, dynamic) listener;


  const BannerAd({
    Key key,
    this.adUnitId,
    this.adSize = AdSize.HEIGHT_50,
    this.autoRefreshTime = 0,
    this.listener,
    this.keepAlive = false,
  }) : super(key: key);

  @override
  _BannerAdState createState() => _BannerAdState();
}

class _BannerAdState extends State<BannerAd> with AutomaticKeepAliveClientMixin {

  var containerHeight = 0.5;


  @override
  Widget build(BuildContext context) {
    if (!Platform.isAndroid) {
      return null;
    }

    var params = <String, dynamic>{
      "adHeight": widget.adSize.height,
      "adUnitId": widget.adUnitId,
      "autoRefreshTime": widget.autoRefreshTime
    };

    Widget platformView = AndroidView(
      viewType: BannerAd.CHANNEL_BANNER,
      creationParams: params,
      creationParamsCodec: StandardMessageCodec(),
      onPlatformViewCreated: _onViewCreated,
    );

    return Container(
      child: platformView,
      color: Colors.transparent,
      height: containerHeight,
    );
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;


  void _onViewCreated(int id) {
    final channel = MethodChannel('${BannerAd.CHANNEL_BANNER}_$id');

    channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
      case "clicked":
        widget.listener?.call(BannerAdEvent.CLICKED, call.arguments);
        break;

      case "failed":
        widget.listener?.call(BannerAdEvent.FAILED, call.arguments);
        break;

      case "loaded":
        var adHeight = call.arguments["adHeight"];

        if (adHeight == null || adHeight <= 0) {
          adHeight = widget.adSize.height;
        }

        setState(() {
          containerHeight = adHeight.toDouble();
        });

        widget.listener?.call(BannerAdEvent.LOADED, call.arguments);
        break;
      }
    });
  }
}