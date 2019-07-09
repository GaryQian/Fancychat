// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

Path buildPath(Size size, double radius, bool isLeft) {
    Path path = Path();
    path.moveTo(radius, 0);
    path.lineTo(size.width - radius, 0);
    path.quadraticBezierTo(
        size.width, 0, size.width, radius);
    if (isLeft) {
      path.lineTo(size.width, size.height - radius);
      path.quadraticBezierTo(
        size.width, size.height, size.width - radius, size.height);
      path.lineTo(0, size.height);
    } else {
      path.lineTo(size.width, size.height);
      path.lineTo(radius, size.height);
      path.quadraticBezierTo(
        0, size.height, 0, size.height - radius);
    }
    path.lineTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);
    path.close();

    return path;
}