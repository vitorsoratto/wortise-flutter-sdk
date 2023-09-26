import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'base_ad.dart';
import 'wortise_sdk.dart';

class AdWidget extends StatefulWidget {

  static const CHANNEL_AD_WIDGET = "${WortiseSdk.CHANNEL_MAIN}/adWidget";


  final BaseAd ad;

  final bool keepAlive;


  const AdWidget({
    Key? key,
    required this.ad,
    this.keepAlive = false,
  }) : super(key: key);

  @override
  _AdWidgetState createState() => _AdWidgetState();
}

class _AdWidgetState extends State<AdWidget> with AutomaticKeepAliveClientMixin {

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (!Platform.isAndroid) {
      return Container();
    }

    var params = <String, dynamic>{
      "adId": widget.ad.adId
    };

    return AndroidView(
      viewType: AdWidget.CHANNEL_AD_WIDGET,
      creationParams: params,
      creationParamsCodec: StandardMessageCodec(),
    );
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;
}