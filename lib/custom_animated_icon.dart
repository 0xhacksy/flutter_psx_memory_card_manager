import 'package:flutter/widgets.dart';
import 'package:flutter_memory_card/pixel_image.dart';

class CustomAnimatedIcon extends StatefulWidget {
  const CustomAnimatedIcon({
    super.key,
    required this.icons,
  });
  final List<List<int>> icons;

  @override
  State<CustomAnimatedIcon> createState() => _CustomAnimatedIconState();
}

class _CustomAnimatedIconState extends State<CustomAnimatedIcon>
    with TickerProviderStateMixin {
  late AnimationController _animationController =
      _animationController = AnimationController(
    lowerBound: 0,
    upperBound: (widget.icons.length - 1).toDouble(),
    duration: const Duration(
      seconds: 3,
    ),
    vsync: this,
  )..forward();

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return PixelImage(
            width: 64,
            height: 64,
            pixels: widget.icons[_animationController.value.round()],
          );
        });
  }
}
