import 'package:flutter/material.dart';
import 'package:glass_kit/glass_kit.dart';

class Back extends StatelessWidget {
  const Back({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: GlassContainer(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.80),
            Colors.white.withValues(alpha: 0.30),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderGradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.60),
            Colors.white.withValues(alpha: 0.10),
            Colors.purpleAccent.withValues(alpha: 0.05),
            Colors.purpleAccent.withValues(alpha: 0.60),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.39, 0.40, 1.0],
        ),
        blur: 20,
        borderRadius: BorderRadius.circular(24.0),
        borderWidth: 1.0,
        elevation: 3.0,
        isFrostedGlass: true,
        shadowColor: Colors.purple.withValues(alpha: 0.20),
        width: 45,
        height: 45,
        // decoration: BoxDecoration(
        //     color: Colors.grey.withAlpha(200),
        //     borderRadius: BorderRadius.circular(50)),
        child: Icon(Icons.arrow_back_ios_new_rounded),
      ),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }
}
