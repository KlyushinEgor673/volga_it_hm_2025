import 'package:flutter/material.dart';
import 'package:glass_kit/glass_kit.dart';

class Back extends StatelessWidget {
  const Back({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
            color: Colors.grey.withAlpha(200),
            borderRadius: BorderRadius.circular(50)),
        child: Icon(Icons.arrow_back_ios_new_rounded),
      ),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }
}
