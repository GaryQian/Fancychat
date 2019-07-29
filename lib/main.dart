// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'dart:convert';
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
      body: FutureBuilder(
          future: getResponse('responses/response.json'),
          builder:
              (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }
            return Center(
              child: ListView.separated(
                itemCount: snapshot.data.length,
                padding: const EdgeInsets.only(left: 20, right: 20, top: 100),
                itemBuilder: (BuildContext context, int index) {
                  Map<String, dynamic> bubbleData =
                      snapshot.data[index] as Map<String, dynamic>;
                  bool isLeft = bubbleData["isLeft"];
                  return Row(children: [
                    Spacer(flex: !isLeft ? 100 : 1),
                    InteractiveBubble(
                      isLeft: isLeft,
                      data: bubbleData,
                    ),
                    Spacer(flex: isLeft ? 100 : 1),
                  ]);
                },
                separatorBuilder: (BuildContext context, int index) =>
                    SizedBox(height: 35),
              ),
            );
          }),
    );
  }

  Future<List<dynamic>> getResponse(String assetName) async {
    String data = await DefaultAssetBundle.of(context).loadString(assetName);
    return jsonDecode(data);
  }
}

class InteractiveBubble extends StatefulWidget {
  InteractiveBubble({
    this.isLeft,
    this.data,
  });

  final double minScale = 0.5;
  final double maxScale = 2.5;

  final Map<String, dynamic> data;

  final bool isLeft;

  @override
  State<StatefulWidget> createState() => InteractiveBubbleState();
}

class InteractiveBubbleState extends State<InteractiveBubble>
    with SingleTickerProviderStateMixin {
  InteractiveBubbleState();

  double _fontScale = 1;
  double _startScale = 1;

  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: (scaleDetails) => setState(() => _startScale = _fontScale),
      onScaleUpdate: (ScaleUpdateDetails scaleDetails) {
        setState(() {
          _fontScale = (scaleDetails.scale * _startScale)
              .clamp(widget.minScale, widget.maxScale);
        });
      },
      child: BubbleBuilder().buildBubbleWithData(widget.data, _fontScale),
    );
  }
}

class BubbleBuilder {
  Bubble buildBubbleWithData(Map<String, dynamic> data, double scale) {
    bool isLeft = data['isLeft'];
    double strutFontSize = data['strutFontSize'];
    List<InlineSpan> spans = [];
    List<dynamic> spansData = data['spans'];
    for (Map<String, dynamic> spanData in spansData) {
      String type = spanData['type'];
      switch (type) {
        case 'text':
          spans.add(TextSpan(
              text: spanData['text'],
              style: TextStyle(
                  fontSize: spanData['fontSize'] * scale, color: Colors.black)));
          break;
        case 'image':
          spans.add(WidgetSpan(
              child: Image.asset(spanData['asset'],
                  width: spanData['width'] * scale, height: spanData['height'] * scale)));
          break;
      }
    }
    Text text = Text.rich(
      TextSpan(children: spans),
      strutStyle: StrutStyle(fontSize: strutFontSize, height: 1.1),
    );
    return Bubble(isLeft: isLeft, text: text);
  }
}

class Bubble extends StatelessWidget {
  Bubble({
    this.isLeft,
    this.text,
  });

  final double padding = 15;
  final double radius = 15;

  final bool isLeft;
  final Text text;

  @override
  Widget build(BuildContext context) {
    List<Color> gradientColors = isLeft
        ? [Colors.grey[200], Colors.grey[350]]
        : [Colors.lightGreenAccent[700], Colors.green[600]];
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
            maxWidth: MediaQuery.of(context).size.width * 0.7,
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
