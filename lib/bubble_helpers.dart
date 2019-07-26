// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

RRect buildRRect(Size size, double radius, bool isLeft) {
  Radius bottomLeft = Radius.circular(isLeft ? 0 : radius);
  Radius bottomRight = Radius.circular(isLeft ? radius : 0);
  return RRect.fromRectAndCorners(
      Rect.fromLTRB(0, 0, size.width, size.height),
      topLeft: Radius.circular(radius),
      topRight: Radius.circular(radius),
      bottomLeft: bottomLeft,
      bottomRight: bottomRight);
}
