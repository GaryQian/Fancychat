// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';

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
  String _text;
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

  int _getTappedIndex(Offset offset, BuildContext context) {
    TextPainter textPainter = TextPainter(text: _textSpan, strutStyle: _strutStyle);
    final RenderBox renderBox = _richTextKey.currentContext.findRenderObject();
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
    TextPosition position = textPainter.getPositionForOffset(offset);
    return position.offset;
  }

  void _tapToAddTextField(Offset offset, BuildContext context) {
    int tappedIndex = _getTappedIndex(offset, context);

    int spanIndex = 0;
    int characterIndex = 0;
    if (_text.length > tappedIndex) {
      String before = _text.substring(0, tappedIndex);
      String after = _text.substring(tappedIndex);
      print('before $before after $after');
      TextSpan newFirstSpan = TextSpan(
        text: after,
        style: _textSpan.style,
      );
      _spans.insert(0, newFirstSpan);
      _text = before;
    } else {
      int totalCharacterIndex = _text.length;
      for (InlineSpan span in _spans) {
        int characterIndexBeforeCounting = totalCharacterIndex;
        if (span is WidgetSpan) {
          totalCharacterIndex++;
        } else {
          TextSpan textSpan = span as TextSpan;
          totalCharacterIndex += textSpan.text.length;
        }
        if (tappedIndex > totalCharacterIndex) {
          spanIndex++;
          continue;
        }
        characterIndex = tappedIndex - characterIndexBeforeCounting;
      }
    }
    InlineSpan selectedSpan = _spans[spanIndex];
    WidgetSpan newSpan = WidgetSpan(
        child: Container(
            child: TextField(
              style: selectedSpan.style,
              onSubmitted: (String value) {
                setState(() {
                  _reconstructSpans(value, selectedSpan.style);
                });
              },
            ),
            width: 100));
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
          text: wholeSpan.text.substring(characterIndex),
          style: wholeSpan.style);
      _spans.replaceRange(spanIndex, spanIndex + 1, [before]);
      _spans.insert(spanIndex + 1, newSpan);
      _spans.insert(spanIndex + 2, after);
      _textFieldSpanIndex = spanIndex + 1;
    }

    print(_spans);
  }

  void _reconstructSpans(String textFieldText, TextStyle textFieldSpanStyle) {
    // Adding spans to main text
    int index = 0;
    for (InlineSpan span in _spans) {
      if (index == _textFieldSpanIndex) {
        _text += textFieldText;
      } else if (span is TextSpan && span.style == _textSpan.style) {
        _text += span.text;
      } else {
        break;
      }
      index++;
    }
    // Reconstructing the remaining spans
    List<InlineSpan> newSpans = List();
    TextStyle lastStyle;
    InlineSpan lastSpan;
    for (int i = index; i < _spans.length; i++) {
      InlineSpan span = _spans[i];
      if (index == _textFieldSpanIndex) {
        span = TextSpan(text: textFieldText, style: textFieldSpanStyle);
      }
      if (span is TextSpan && lastSpan is TextSpan) {
        TextSpan textSpan = span;
        TextSpan lastTextSpan = lastSpan;
        if (lastStyle == null || textSpan.style != lastStyle) {
          newSpans.add(span);
        } else {
          _combineTextSpan(
              lastTextSpan.text, textSpan.text, lastTextSpan.style);
        }
      } else {
        newSpans.add(span);
      }
      lastSpan = span;
    }
    _spans = newSpans;
  }

  TextSpan _combineTextSpan(String a, String b, TextStyle style) {
    return TextSpan(text: a + b, style: style);
  }

  TextSpan _buildTextSpan(String text, List<InlineSpan> spans) {
    return TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.black,
          fontSize: widget.fontSize * _fontScale,
        ),
        children: spans);
  }

  Widget _createAndCacheRichText() {
    if (_text == null || _spans == null) {
      _text = '看！Flutter Gallery APP！';
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
    _textSpan = _buildTextSpan(_text, _spans);
    RichText richText =  RichText(key: _richTextKey, text: _textSpan, strutStyle: _strutStyle);
    return richText;
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
      onTapUp: (TapUpDetails details) {
        final RenderBox renderBox =
            _richTextKey.currentContext.findRenderObject();
        setState(() {
          _tapToAddTextField(
            renderBox.globalToLocal(details.globalPosition), context);
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
