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
            bool isLeft = index % 2 == 1;
            List<Color> colors = isLeft
                ? [Colors.grey[200], Colors.grey[350]]
                : [Colors.lightGreenAccent[700], Colors.green[600]];
            return Row(children: [
              Spacer(flex: !isLeft ? 100 : 1),
              InteractiveBubble(
                maxWidth: 300,
                fontSize: 20,
                minScale: 0.5,
                maxScale: 2.5,
                gradientColors: colors,
                isLeft: isLeft,
                radius: 15,
              ),
              Spacer(flex: isLeft ? 100 : 1),
            ]);
          },
          separatorBuilder: (BuildContext context, int index) =>
              SizedBox(height: 35),
        ),
      ),
    );
  }
}

class InteractiveBubble extends StatefulWidget {
  InteractiveBubble({
    this.maxWidth,
    this.fontSize,
    this.minScale,
    this.maxScale,
    this.gradientColors,
    this.isLeft,
    this.radius,
  });

  final double maxWidth;
  final double fontSize;
  final double minScale;
  final double maxScale;
  final double radius;

  final List<Color> gradientColors;
  final bool isLeft;

  @override
  State<StatefulWidget> createState() => InteractiveBubbleState();
}

class InteractiveBubbleState extends State<InteractiveBubble>
    with SingleTickerProviderStateMixin {
  InteractiveBubbleState();

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
      });
  }

  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: (scaleDetails) => setState(() => _startScale = _fontScale),
      onScaleUpdate: (ScaleUpdateDetails scaleDetails) {
        setState(() {
          _fontScale = (scaleDetails.scale * _startScale)
              .clamp(widget.minScale, widget.maxScale);
        });
      },
      child: Bubble(
        isLeft: widget.isLeft,
        radius: widget.radius,
        gradientColors: widget.gradientColors,
        maxWidth: widget.maxWidth,
        text: Text.rich(
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
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class Bubble extends StatelessWidget {
  Bubble(
      {this.isLeft,
      this.radius,
      this.gradientColors,
      this.maxWidth,
      this.text});

  final double padding = 15;

  final bool isLeft;
  final double radius;
  final List<Color> gradientColors;
  final double maxWidth;
  final Text text;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BubbleShadowPainter(isLeft: isLeft, radius: radius),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(radius),
            topRight: Radius.circular(radius),
            bottomLeft: isLeft ? Radius.zero : Radius.circular(radius),
            bottomRight: isLeft ? Radius.circular(radius) : Radius.zero),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
          ),
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomLeft,
            ),
          ),
          child: text,
        ),
      ),
    );
  }
}

class BubbleShadowPainter extends CustomPainter {
  BubbleShadowPainter({this.isLeft, this.radius});

  final double radius;
  final bool isLeft;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawShadow(Path()..addRRect(buildRRect(size, radius, isLeft)),
        Colors.black87, 5.0, false);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  RRect buildRRect(Size size, double radius, bool isLeft) {
    Radius bottomLeft = isLeft ? Radius.zero : Radius.circular(radius);
    Radius bottomRight = isLeft ? Radius.circular(radius) : Radius.zero;
    return RRect.fromRectAndCorners(
        Rect.fromLTRB(0, 0, size.width, size.height),
        topLeft: Radius.circular(radius),
        topRight: Radius.circular(radius),
        bottomLeft: bottomLeft,
        bottomRight: bottomRight);
  }
}
