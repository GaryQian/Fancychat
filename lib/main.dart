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

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Center(
        child: Transform.scale(
          scale: animation.value,
          child: GestureDetector(
            child: Bubble(),
            onDoubleTap: () {
              if (animation.status == AnimationStatus.dismissed) {
                controller.forward();
              } else if (animation.status == AnimationStatus.completed) {
                controller.reverse();
              }
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

class Bubble extends StatelessWidget {
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: BubbleShaperClipper(curvePercentage: 0.05),
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
                    child:
                        SizedBox(width: 300, height: 400, child: GalleryApp()),
                  ),
                ),
              ), // WidgetSpan
              TextSpan(text: 'What do you think?')
            ],
          ), // TextSpan
        ), // RichText
      ), // Container// ClipRRect/ Stack
    );
  }
}

class BubbleShaperClipper extends CustomClipper<Path> {
  final curvePercentage;

  BubbleShaperClipper({this.curvePercentage}) {
    assert(this.curvePercentage < 0.5);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(size.width * curvePercentage, 0);
    path.lineTo(size.width * (1 - curvePercentage), 0);
    path.quadraticBezierTo(
        size.width, 0, size.width, size.height * curvePercentage);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width * curvePercentage, size.height);
    path.quadraticBezierTo(
        0, size.height, 0, size.height * (1 - curvePercentage));
    path.lineTo(0, size.height * curvePercentage);
    path.quadraticBezierTo(0, 0, size.width * curvePercentage, 0);
    path.close();
    return path;
  }
}
