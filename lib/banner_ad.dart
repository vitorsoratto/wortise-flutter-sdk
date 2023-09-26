import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ad_size.dart';
import 'wortise_sdk.dart';

enum BannerAdEvent {
  CLICKED,
  FAILED_TO_LOAD,
  IMPRESSION,
  LOADED,
}

class BannerAd extends StatefulWidget {

  static const CHANNEL_BANNER = "${WortiseSdk.CHANNEL_MAIN}/bannerAd";


  final AdSize adSize;

  final String adUnitId;

  final int autoRefreshTime;

  final bool keepAlive;

  final void Function(BannerAdEvent, dynamic)? listener;


  const BannerAd({
    Key? key,
    required this.adUnitId,
    this.adSize = AdSize.HEIGHT_50,
    this.autoRefreshTime = 0,
    this.listener,
    this.keepAlive = false,
  }) : super(key: key);

  @override
  _BannerAdState createState() => _BannerAdState();
}

class _BannerAdState extends State<BannerAd> with AutomaticKeepAliveClientMixin {

  double? containerHeight;


  @override
  void initState() {
    super.initState();

    _updateState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (!Platform.isAndroid) {
      return Container();
    }

    var params = <String, dynamic>{
      "adSize": widget.adSize.toMap,
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


  void _updateState({ int? adHeight }) {
    var height = adHeight;

    if (height == null || height <= 0) {
      height = widget.adSize.height;
    }

    if (height <= 0) {
      height = null;
    }

    setState(() {
      containerHeight = height?.toDouble() ?? double.infinity;
    });
  }

  void _onViewCreated(int id) {
    final channel = MethodChannel('${BannerAd.CHANNEL_BANNER}_$id');

    channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
      case "clicked":
        widget.listener?.call(BannerAdEvent.CLICKED, call.arguments);
        break;

      case "failedToLoad":
        widget.listener?.call(BannerAdEvent.FAILED_TO_LOAD, call.arguments);
        break;

      case "impression":
        widget.listener?.call(BannerAdEvent.IMPRESSION, call.arguments);
        break;

      case "loaded":
        var adHeight = call.arguments["adHeight"];

        _updateState(adHeight: adHeight);

        widget.listener?.call(BannerAdEvent.LOADED, call.arguments);
        
        break;
      }
    });
  }
}