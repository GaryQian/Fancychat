// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

Path buildPath(Size size, double radius, bool isLeft) {
  Path path = Path();
  path.moveTo(radius, 0);
  path.lineTo(size.width - radius, 0);
  path.quadraticBezierTo(size.width, 0, size.width, radius);
  if (isLeft) {
    path.lineTo(size.width, size.height - radius);
    path.quadraticBezierTo(
        size.width, size.height, size.width - radius, size.height);
    path.lineTo(0, size.height);
  } else {
    path.lineTo(size.width, size.height);
    path.lineTo(radius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - radius);
  }
  path.lineTo(0, radius);
  path.quadraticBezierTo(0, 0, radius, 0);
  path.close();

  return path;
}

// The the total index the [offset] is on in the [textPainter].
int getTappedIndex({@required TextPainter textPainter, @required Offset offset}) {
  assert(textPainter != null);
  assert(offset != null);
  return textPainter.getPositionForOffset(offset).offset;
}

// Get which span a particular [offset] is in.
TappedOffset getTappedOffset({@required int tappedIndex, @required List<InlineSpan> spans}) {
  assert(tappedIndex != null);
  assert(spans != null);
  int spanIndex = 0;
  int characterIndex = 0;
  int totalIndex = 0;
  for (int index = 0; index < spans.length; index++) {
    InlineSpan span = spans[index];
    if (span is TextSpan) {
      if (totalIndex + span.text.length < tappedIndex) {
        totalIndex += span.text.length;
      } else {
        characterIndex = tappedIndex - totalIndex;
        spanIndex = index;
        break;
      }
    } else if (span is PlaceholderSpan) {
      totalIndex++;
    }
  }
  return TappedOffset(spanIndex: spanIndex, characterIndex: characterIndex);
}

/// Describe the where a tap is happened in a list of `InlineSpans`
class TappedOffset {
  /// The index of the span that is tapped on.
  final int spanIndex;

  /// The index of the character that is tapped on within a `TextSpan`.
  final int characterIndex;

  TappedOffset({@required this.spanIndex, @required this.characterIndex});
}
