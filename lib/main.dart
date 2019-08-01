// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'gallery/app.dart';

const String kEmoji1 = "assets/devil.gif";
const String kEmoji2 = "assets/tears.gif";

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
      platform: TargetPlatform.iOS,
      fontFamily: 'PingFang SC',
    ),
    home: MyHomePage(title: '聊天气泡'),
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
        return Row(children: [
          Spacer(flex: 100),
          Bubble(),
          Spacer(flex: 1),
        ]);
      },
      separatorBuilder: (BuildContext context, int index) =>
          SizedBox(height: 35),
    )));
  }
}

class Bubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 330),
      child: Text('大家好，欢迎来到我们的演示'),
    );
  }
}
