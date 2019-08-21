import 'package:flutter/material.dart';
import 'gallery/app.dart';

const String kFlutterLogo = 'assets/flutter2.gif';


class Bubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 330),
      child: Text('大家好，欢迎来到我们的演示'),
    );
  }
}
