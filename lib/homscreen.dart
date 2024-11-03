import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class WinterAnimation extends StatefulWidget {
  const WinterAnimation({super.key});

  @override
  _WinterAnimationState createState() => _WinterAnimationState();
}

class _WinterAnimationState extends State<WinterAnimation>
    with TickerProviderStateMixin {
  final int starCount = 400;
  final List<AnimationController> _controllers = [];
  final List<Animation<double>> _animations = [];
  final List<Animation<Color?>> _colorAnimations = [];
  final Random random = Random();

  final List<String> texts = [
    "Winter",
    "is",
    "Coming",
  ];
  final List<AnimationController> _textControllers = [];
  final List<Animation<Offset>> _textAnimations = [];
  int _currentTextIndex = 0;
  List<Color> _currentGradientColors = [Colors.purple, Colors.blue];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < starCount; i++) {
      final duration = Duration(milliseconds: 3000 + random.nextInt(6000));
      final controller = AnimationController(
        duration: duration,
        vsync: this,
      )..repeat(reverse: false);

      final positionAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Curves.bounceOut),
      );

      final colorAnimation = ColorTween(
        begin: Colors.white,
        end: Color.fromARGB(
          255,
          random.nextInt(256),
          random.nextInt(256),
          random.nextInt(256),
        ),
      ).animate(CurvedAnimation(parent: controller, curve: Curves.bounceOut));

      _controllers.add(controller);
      _animations.add(positionAnimation);
      _colorAnimations.add(colorAnimation);
    }

    // Set up animations for each text
    for (int i = 0; i < texts.length; i++) {
      final controller = AnimationController(
        duration: const Duration(seconds: 2),
        vsync: this,
      );
      final animation = Tween<Offset>(
        begin: const Offset(0, -1), // Start slightly above the screen
        end: const Offset(0, 0), // Move to center
      ).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );

      _textControllers.add(controller);
      _textAnimations.add(animation);
    }

    // Start the first text animation
    _animateText();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var textController in _textControllers) {
      textController.dispose();
    }
    super.dispose();
  }

  void _animateText() {
    // Start current text animation
    _textControllers[_currentTextIndex].forward();

    // Change gradient colors and loop to the next text
    Future.delayed(const Duration(seconds: 1), () {
      _textControllers[_currentTextIndex].reverse().then((_) {
        setState(() {
          // Update to a new gradient for each word
          _currentGradientColors = [
            Color.fromARGB(255, random.nextInt(256), random.nextInt(256),
                random.nextInt(256)),
            Color.fromARGB(255, random.nextInt(256), random.nextInt(256),
                random.nextInt(256)),
          ];

          // Move to the next text
          _currentTextIndex = (_currentTextIndex + 1) % texts.length;
        });
        _animateText(); // Loop to the next text
      });
    });
  }

  Widget _buildStar(int index) {
    final double size = random.nextDouble() * 7 + 1;
    final double left = random.nextDouble() * MediaQuery.of(context).size.width;

    return AnimatedBuilder(
      animation: _animations[index],
      builder: (context, child) {
        double top =
            _animations[index].value * MediaQuery.of(context).size.height;

        if (top > MediaQuery.of(context).size.height - size) {
          top = MediaQuery.of(context).size.height - size;
        }

        return Positioned(
          left: left,
          top: top,
          child: SizedBox(
            width: size,
            height: size,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _colorAnimations[index].value,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Stars
          ...List.generate(starCount, (index) => _buildStar(index)),

          // Animated gradient text
          Center(
            child: SlideTransition(
              position: _textAnimations[_currentTextIndex],
              child: ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                    colors: _currentGradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds);
                },
                child: Text(
                  texts[_currentTextIndex],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
