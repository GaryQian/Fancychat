// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'gallery/app.dart';

const String emoji1 = "assets/devil.gif";
const String emoji2 = "assets/tears.gif";

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
      platform: TargetPlatform.iOS,
      fontFamily: 'PingFang SC',
    ),
    home: MyHomePage(title: 'Fancy Chat Bubble'),
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

class _BubbleState extends State<Bubble> {
  final double _fontSize = 20;
  double _fontScale = 1;
  double _startScale = 1;
  final double _minScale = 0.5;
  final double _maxScale = 2.5;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: (ScaleStartDetails scaleDetails) {
        setState(() => _startScale = _fontScale);
      },
      onScaleUpdate: (ScaleUpdateDetails scaleUpdateDetails) {
        setState(() => _fontScale = (scaleUpdateDetails.scale * _startScale)
            .clamp(_minScale, _maxScale));
      },
      child: CustomPaint(
        painter: BubbleShadowPainter(),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
              bottomLeft: Radius.circular(15)),
          child: Container(
            constraints: BoxConstraints(maxWidth: 350),
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.lightGreenAccent[700], Colors.green[600]],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomLeft)),
            child: Text.rich(
              buildTextSpan(),
              strutStyle: StrutStyle(fontSize: _fontSize * _fontScale),
            ),
          ),
        ),
      ),
    );
  }

  TextSpan buildTextSpan() {
    return TextSpan(
        style: TextStyle(
            fontSize: _fontSize * _fontScale,
            decoration: TextDecoration.underline,
            decorationStyle: TextDecorationStyle.wavy,
            decorationColor: Colors.red),
        children: <InlineSpan>[
          TextSpan(text: 'Hello everyone.\n'),
          WidgetSpan(
              child: Image.asset(
            emoji1,
            width: 25 * _fontScale,
            height: 25 * _fontScale,
          )),
          WidgetSpan(
              child: Image.asset(
            emoji2,
            width: 25 * _fontScale,
            height: 25 * _fontScale,
          )),
          TextSpan(
              text: 'The small text\n',
              style: TextStyle(fontSize: _fontSize / 2 * _fontScale)),
          WidgetSpan(
              child: SizedBox(width: 300, height: 400, child: GalleryApp())),
        ]);
  }
}

class BubbleShadowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawShadow(
        Path()
          ..addRRect(RRect.fromRectAndCorners(
              Rect.fromLTWH(0, 0, size.width, size.height),
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
              bottomLeft: Radius.circular(15))),
        Colors.black87,
        5.0,
        false);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}