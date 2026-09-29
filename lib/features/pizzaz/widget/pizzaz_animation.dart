import 'package:flutter/material.dart';

class PizzazAnimation extends StatefulWidget {
  const PizzazAnimation({ super.key, required this.child,});
  final Widget child;

  @override
  State<PizzazAnimation> createState() => _PizzazAnimationState();
}

class _PizzazAnimationState extends State<PizzazAnimation> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _bounce;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _bounce = Tween<double>( begin: 0,  end: -12,).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounce,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bounce.value),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}