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
    controller =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    animation = Tween<double>(begin: 1, end: 1.1).animate(controller);
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Center(
        child: AnimatedBubble(
          animation: animation,
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

class ShapesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = Colors.green;
    paint.style = PaintingStyle.fill;
    Path path = Path();
    path.moveTo(0, 0);
    path.addPolygon(<Offset>[
      Offset(0, 0),
      Offset(40, 0),
      Offset(50, 50),
      Offset(0, 40),
    ], true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return null;
  }
}

class AnimatedBubble extends AnimatedWidget {
  AnimatedBubble({Key key, Animation<double> animation})
      : super(key: key, listenable: animation);

  Widget build(BuildContext context) {
    final Animation<double> animation = listenable; 
    return Transform.scale(
          scale: animation.value,
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Stack(
            children: <Widget>[
              Positioned(
                right: 0,
                bottom: 0,
                child: Transform.translate(
                  offset: Offset(5, 5),
                  child: CustomPaint(
                    painter: ShapesPainter(),
                    child: Container(
                        height: 50, width: 50),
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(17)),
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
                        fontSize: 20,
                        color: Colors.black,
                      ),
                      children: <InlineSpan>[
                        WidgetSpan(
                          child: MediaQuery.removePadding(
                            context: context,
                            removeBottom: true,
                            removeTop: true,
                            removeLeft: true,
                            removeRight: true,
                            child: ClipRect(
                              child: SizedBox(
                                  width: 300, height: 400, child: GalleryApp()),
                            ),
                          ),
                        ), // WidgetSpan
                        TextSpan(text: 'What do you think?')
                      ],
                    ), // TextSpan
                  ), // RichText
                ), // Container
              ), // ClipRRect
            ],
          ), // Stack
          Text(
            '',
            style: Theme.of(context).textTheme.display1,
          ),
        ],
      ),
    );
  }
}
