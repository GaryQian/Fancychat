// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'gallery/app.dart';

const String kEmoji1 = "assets/devil.gif";
const String kEmoji2 = "assets/tears.gif";

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
      platform: TargetPlatform.iOS,
      fontFamily: 'PingFang SC',
    ),
    home: MyHomePage(title: '聊天气泡'),
  ));
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: Center(
            child: ListView.separated(
      itemCount: 1,
      padding: const EdgeInsets.only(left: 20, right: 20, top: 100),
      itemBuilder: (BuildContext context, int index) {
        return Row(children: [
          Spacer(flex: 100),
          Bubble(),
          Spacer(flex: 1),
        ]);
      },
      separatorBuilder: (BuildContext context, int index) =>
          SizedBox(height: 35),
    )));
  }
}

class Bubble extends StatefulWidget {
  @override
  _BubbleState createState() => _BubbleState();
}

const double _defaultFontSize = 20;

class _BubbleState extends State<Bubble> {
  double _fontSize = _defaultFontSize;
  double _startScale = 1;
  double _fontScale = 1;

  double get scaledFontSize {
    return _fontSize * _fontScale;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: (ScaleStartDetails scaleStartDetails) {
        _startScale = _fontScale;
      },
      onScaleUpdate: (ScaleUpdateDetails scaleUpdateDetails) {
        setState(() {
          _fontScale = (scaleUpdateDetails.scale * _startScale).clamp(0.5, 2.5);
          _fontSize = _defaultFontSize * _fontScale;
        });
      },
      child: Container(
        constraints: BoxConstraints(maxWidth: 330),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightGreenAccent[700], Colors.green[500]],
            begin: Alignment.topLeft,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
            bottomLeft: Radius.circular(15),
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              offset: Offset(10, 10),
              color: Colors.black38,
            ),
          ],
        ),
        padding: EdgeInsets.all(15),
        child: Text.rich(
          buildTextSpan(),
          strutStyle: StrutStyle(fontSize: _fontSize),
        ),
      ),
    );
  }

  TextSpan buildTextSpan() {
    return TextSpan(
      style: TextStyle(fontSize: _fontSize),
      children: [
        TextSpan(text: '欢迎大家加入我们的演示'),
        WidgetSpan(
            child: Image.asset(kEmoji1,
                width: 25 * _fontScale, height: 25 * _fontScale)),
        WidgetSpan(
            child: Image.asset(kEmoji2,
                width: 25 * _fontScale, height: 25 * _fontScale)),
        TextSpan(
            text: '欢迎大家加入我们的演示\n', style: TextStyle(fontSize: _fontSize / 2)),
        WidgetSpan(
          child: ClipRect(
            child: SizedBox(
              width: 300,
              height: 500,
              child: GalleryApp(),
            ),
          ),
        ),
      ],
    );
  }
}
