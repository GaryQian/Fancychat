// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'gallery/app.dart';

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
      platform: TargetPlatform.iOS,
      fontFamily: 'PingFang SC',
    ),
    home: MyHomePage(title: 'Flutter Demo Home Page'),
  ));
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  Animation<double> animation;
  AnimationController controller;

  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    animation = Tween<double>(begin: 1, end: 1.2).animate(controller)
      ..addListener(() {
        setState(() {});
      });
  }

  double fontSize = 20;
  final double startingFontSize = 20;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Center(
        child: Transform.scale(
          scale: animation.value,
          child: GestureDetector(
            child: Bubble(fontSize: fontSize, minScale: 0.5, maxScale: 2.5),
            onDoubleTap: () {
              if (animation.status == AnimationStatus.dismissed) {
                controller.forward();
              } else if (animation.status == AnimationStatus.completed) {
                controller.reverse();
              }
            },
            onScaleUpdate: (ScaleUpdateDetails scaleDetails) {
              setState(() {
                fontSize = startingFontSize*scaleDetails.scale;
              });
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class Bubble extends StatefulWidget {

  final double fontSize;
  final double minScale;
  final double maxScale;

  Bubble({
    this.fontSize,
    this.minScale,
    this.maxScale,
  });

  @override
  State<StatefulWidget> createState() {
    return new BubbleState();
  }
}

class BubbleState extends State<Bubble> {
  double _fontScale = 1;
  double _startScale = 1;

  BubbleState();

  Widget build(BuildContext context) {
    return ClipPath(
      clipper: BubbleShaperClipper(radius: 15),
      child: GestureDetector(
        onScaleStart: (scaleDetails) => setState(() => _startScale = _fontScale),
        onScaleUpdate: (ScaleUpdateDetails scaleDetails) {
          setState(() {
            _fontScale = (scaleDetails.scale * _startScale).clamp(widget.minScale, widget.maxScale);
          });
        },
        child: Container(
          width: 300,
          // height: 600,
          decoration: BoxDecoration(
            color: Colors.green,
            border: Border.all(
              color: Colors.green,
              width: 14.0,
            ),
          ),
          child: RichText(
            text: TextSpan(
              text: 'Here is the gallery: ',
              style: TextStyle(
                fontSize: widget.fontSize * _fontScale,
                color: Colors.black,
              ),
              children: <InlineSpan>[
                WidgetSpan(
                  child: ClipRect(
                    child: SizedBox(
                      width: 300,
                      height: 400,
                      child: GalleryApp()
                    ),
                  ),
                ), // WidgetSpan
                TextSpan(text: 'What do you think?')
              ],
              // gestureRecognizer: GestureRecognizer(),
            ), // TextSpan
          ), // RichText
        ), // Container
      ), // GestureDetector
    );
  }
}

class BubbleShaperClipper extends CustomClipper<Path> {
  BubbleShaperClipper({this.radius}) : assert(radius >= 0);

  final double radius;

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(radius, 0);
    path.lineTo(size.width - radius, 0);
    path.quadraticBezierTo(
        size.width, 0, size.width, radius);
    path.lineTo(size.width, size.height);
    path.lineTo(radius, size.height);
    path.quadraticBezierTo(
        0, size.height, 0, size.height - radius);
    path.lineTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);
    path.close();
    return path;
  }
}
