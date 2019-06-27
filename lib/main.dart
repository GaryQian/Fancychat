// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Thanks for checking out Flutter!
// Like what you see? Tweet us @FlutterDev

import 'package:flutter/material.dart';

import 'gallery/app.dart';

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(
        platform: TargetPlatform.iOS,
        fontFamily: 'PingFang SC',
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    )
  );
}


class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return new Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug paint" (press "p" in the console where you ran
          // "flutter run", or select "Toggle Debug Paint" from the Flutter tool
          // window in IntelliJ) to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Stack(
              children: <Widget>[
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Transform.translate(
                  // Align(
                    offset: Offset(5, 5),
                    // alignment: Alignment(1, 1),
                    // left: 260,
                    // top: 550,
                    // width: 100,
                    // height: 100,
                    // right: 20,
                    // bottom: 0,
                    // child: Container(
                    //   width: 100,
                    //   height: 100,
                    //   decoration: BoxDecoration(
                    //     color: Colors.blue,
                    //     border: Border.all(
                    //       color: Colors.blue,
                    //       width: 14.0,
                    //     ),
                    //   ),
                    // ), // Container
                    child: CustomPaint(
                      painter: ShapesPainter(),
                      child: Container(height: 50, width: 50),
                    ),
                    // child: RotationTransition(
                    //   turns: AlwaysStoppedAnimation(90 / 360),
                    //   child: Material(
                    //     borderRadius: BorderRadius.all(
                    //       Radius.circular(1.5),
                    //     ),
                    //     color: Colors.blue,
                    //     child: Container(
                    //       height: 10.0,
                    //       width: 10.0,
                    //     ),
                    //   ),
                    // ),
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
                                  width: 300,
                                  height: 400,
                                  child: GalleryApp()
                                ),
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
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
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
    // TODO: implement shouldRepaint
    return null;
  }
}
