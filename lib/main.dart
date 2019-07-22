// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

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
            List<Color> colors = isLeft
                ? [Colors.grey[200], Colors.grey[350]]
                : [Colors.lightGreenAccent[700], Colors.green[600]];
            return Row(children: [
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
            ]);
          },
          separatorBuilder: (BuildContext context, int index) =>
              SizedBox(height: 35),
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

  final GlobalKey _richTextKey = GlobalKey();
  TextSpan _textSpan;
  List<InlineSpan> _spans;
  StrutStyle _strutStyle;
  int _textFieldSpanIndex;

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

  /// Builds a TextPainter with current state of the text.
  TextPainter buildTextPainter(RenderBox renderBox) {
    assert(renderBox != null);
    TextPainter textPainter =
    TextPainter(text: _textSpan, strutStyle: _strutStyle);
    final Size size = renderBox.size;
    textPainter.textDirection = TextDirection.ltr;
    textPainter.setPlaceholderDimensions(<PlaceholderDimensions>[
      PlaceholderDimensions(
          size: Size(25 * _fontScale, 25 * _fontScale),
          alignment: PlaceholderAlignment.bottom),
      PlaceholderDimensions(
          size: Size(25 * _fontScale, 25 * _fontScale),
          alignment: PlaceholderAlignment.bottom)
    ]);
    textPainter.layout(minWidth: size.width, maxWidth: size.width);
    return textPainter;
  }

  void _tapToAddTextField(Offset offset, RenderBox renderBox) {
    assert(offset != null);
    assert(renderBox != null);
    TextPainter textPainter = buildTextPainter(renderBox);
    int tappedIndex = getTappedIndex(offset: offset, textPainter: textPainter);

    TappedOffset tappedOffset = getTappedOffset(tappedIndex: tappedIndex, spans: _spans);
    final int spanIndex = tappedOffset.spanIndex;
    final int characterIndex = tappedOffset.characterIndex;
    print('span index $spanIndex');
    print('character index $characterIndex');

    InlineSpan selectedSpan = _spans[spanIndex];
    WidgetSpan newSpan = WidgetSpan(
      alignment: PlaceholderAlignment.baseline,
      baseline: TextBaseline.alphabetic,
      child: Container(
        child: TextField(
          controller: TextEditingController(text: selectedSpan.text.substring(characterIndex, characterIndex+1)),
          style: selectedSpan.style?.copyWith(color: Colors.blue[600]) ?? _textSpan.style.copyWith(color: Colors.blue[600]),
          onSubmitted: (String value) {
            setState(() {
              _reconstructSpans(value, selectedSpan.style);
            });
          },
          decoration: InputDecoration(border:  InputBorder.none,),
        ),
        width: 50)
      );
    if (characterIndex == 0 || selectedSpan is WidgetSpan) {
      // no need to split
      _spans.insert(spanIndex, newSpan);
      _textFieldSpanIndex = 0;
    } else {
      TextSpan wholeSpan = selectedSpan as TextSpan;
      TextSpan before = TextSpan(
          text: wholeSpan.text.substring(0, characterIndex),
          style: wholeSpan.style);
      TextSpan after = TextSpan(
          text: wholeSpan.text.substring(characterIndex + 1),
          style: wholeSpan.style);
      _spans.replaceRange(spanIndex, spanIndex + 1, [before]);
      _spans.insert(spanIndex + 1, newSpan);
      _spans.insert(spanIndex + 2, after);
      _textFieldSpanIndex = spanIndex + 1;
    }
  }

  List<InlineSpan> _reconstructSpans(String textFieldText, TextStyle textFieldSpanStyle) {
    // Reconstructing the remaining spans
    List<InlineSpan> newSpans = List();
    for (int i = 0; i < _spans.length; i++) {
      if (i == _textFieldSpanIndex) {
        newSpans.add(TextSpan(text: textFieldText, style: textFieldSpanStyle));
      } else {
        newSpans.add(_spans[i]);
      }
    }
    _spans = newSpans;
    return newSpans;
  }

  TextSpan _buildTextSpan(List<InlineSpan> spans) {
    return TextSpan(
      // text: text,
      style: TextStyle(
        color: Colors.black,
        fontSize: widget.fontSize * _fontScale,
      ),
      children: spans
    );
  }

  Widget _createAndCacheRichText() {
    if (_spans == null) {
      _spans = <InlineSpan>[
        // WidgetSpan(
        //   child: ClipRect(
        //     child: SizedBox(
        //       width: 300,
        //       height: 400,
        //       child: GalleryApp()
        //     ),
        //   ),
        // ), // WidgetSpan
        TextSpan(
          text: '看！Flutter Gallery APP！',
        ),
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
      ];
    }
    _strutStyle =
      StrutStyle(fontSize: widget.fontSize * _fontScale, height: 1.1);
    _textSpan = _buildTextSpan(_spans);
    print(_buildTextSpan(_spans));
    return RichText(key: _richTextKey, text: _buildTextSpan(List<InlineSpan>.from(_spans)), strutStyle: _strutStyle);
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
      onLongPressStart: (LongPressStartDetails details) {
        final RenderBox renderBox =
            _richTextKey.currentContext.findRenderObject();
        setState(() {
          _tapToAddTextField(
            renderBox.globalToLocal(details.globalPosition), renderBox);
        });
      },
      child: Transform.scale(
        scale: animation.value,
        alignment: Alignment(widget.isLeft ? -1 : 1, 0.5),
        child: CustomPaint(
          painter: BubbleShadowPainter(isLeft: widget.isLeft),
          child: ClipPath(
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
              child: _createAndCacheRichText(),
            ), // Container
          ), // ClipPath
        ), // CustomPaint
      ), // Transform
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class BubbleShaperClipper extends CustomClipper<Path> {
  BubbleShaperClipper({this.isLeft});

  final bool isLeft;

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }

  @override
  Path getClip(Size size) {
    return buildPath(size, 15, isLeft);
  }
}

class BubbleShadowPainter extends CustomPainter {
  BubbleShadowPainter({this.isLeft});

  final bool isLeft;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawShadow(buildPath(size, 15, isLeft), Colors.black87, 5.0, false);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
