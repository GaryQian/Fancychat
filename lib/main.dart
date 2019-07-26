// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'gallery/app.dart';
import 'bubble_helpers.dart';

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

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Center(
        child: ListView.separated(
          itemCount: 1,
          padding: const EdgeInsets.only(left: 20, right: 20, top: 100),
          itemBuilder: (BuildContext context, int index) {
            bool isLeft = index % 2 == 1;
            List<Color> colors = isLeft ?
              [Colors.grey[200], Colors.grey[350]] :
              [Colors.lightGreenAccent[700], Colors.green[600]];
            return Row(
              children: [
                Spacer(flex: !isLeft ? 100 : 1),
                Bubble(
                  width: 300,
                  fontSize: 20,
                  minScale: 0.5,
                  maxScale: 2.5,
                  gradientColors: colors,
                  isLeft: isLeft,
                ),
                Spacer(flex: isLeft ? 100 : 1),
              ]
            );
          },
          separatorBuilder: (BuildContext context, int index) => SizedBox(height: 35),
        ),
      ),
    );
  }
}

class Bubble extends StatefulWidget {
  Bubble({
    this.width,
    this.fontSize,
    this.minScale,
    this.maxScale,
    this.gradientColors,
    this.isLeft,
  });

  final double width;

  final double fontSize;
  final double minScale;
  final double maxScale;

  final List<Color> gradientColors;
  final bool isLeft;

  @override
  State<StatefulWidget> createState() {
    return new BubbleState();
  }
}

class BubbleState extends State<Bubble> with SingleTickerProviderStateMixin {
  BubbleState();

  double _fontScale = 1;
  double _startScale = 1;

  Animation<double> animation;
  AnimationController controller;

  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    animation = Tween<double>(begin: 1, end: 1.15).animate(controller)
      ..addListener(() {
        setState(() {});
      }
    );
  }

  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: (scaleDetails) => setState(() => _startScale = _fontScale),
      onScaleUpdate: (ScaleUpdateDetails scaleDetails) {
        setState(() {
          _fontScale = (scaleDetails.scale * _startScale).clamp(widget.minScale, widget.maxScale);
        });
      },
      child: Transform.scale(
        scale: animation.value,
        alignment: Alignment(widget.isLeft ? -1 : 1, 0.5),
        child: CustomPaint(
          painter: BubbleShadowPainter(isLeft: widget.isLeft),
          child: ClipRRect(
            clipper: BubbleShaperClipper(isLeft: widget.isLeft),
            child: Container(
              width: widget.width,
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomLeft,
                ),
              ),
              child: Text.rich(
                TextSpan(
                  text: '看！Flutter Gallery APP！',
                  style: TextStyle(
                    fontSize: widget.fontSize * _fontScale,
                    color: Colors.black,
                  ),
                  children: <InlineSpan>[
                    // WidgetSpan(
                    //   child: ClipRect(
                    //     child: SizedBox(
                    //       width: 300,
                    //       height: 400,
                    //       child: GalleryApp()
                    //     ),
                    //   ),
                    // ), // WidgetSpan
                    WidgetSpan(
                      child: Image.asset(
                        'assets/tears.gif',
                        width: 25 * _fontScale,
                        height: 25 * _fontScale,
                      ),
                    ), // WidgetSpan
                    WidgetSpan(
                      child: Image.asset(
                        'assets/devil.gif',
                        width: 25 * _fontScale,
                        height: 25 * _fontScale,
                      ),
                    ), // WidgetSpan
                    TextSpan(
                      text: 'Strut让小字体的文字有更多的空间。',
                      style: TextStyle(
                        fontSize: widget.fontSize * _fontScale / 2,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: '您觉得如何？',
                    ),
                  ],
                ),
                strutStyle: StrutStyle(
                  fontSize: widget.fontSize * _fontScale,
                  height: 1.1,
                ),
              ),
            ),
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

class BubbleShaperClipper extends CustomClipper<RRect> {
  BubbleShaperClipper({this.isLeft});

  final bool isLeft;

  @override
  bool shouldReclip(CustomClipper<RRect> oldClipper) {
    return true;
  }

  @override
  RRect getClip(Size size) {
    return buildRRect(size, 15, isLeft);
  }
}

class BubbleShadowPainter extends CustomPainter {

  BubbleShadowPainter({this.isLeft});

  final bool isLeft;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawShadow(Path()..addRRect(buildRRect(size, 15, isLeft)), Colors.black87, 5.0, false);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
