import 'package:flutter/widgets.dart';
import 'package:flutter_memory_card/mc.dart';

class RegionWidget extends StatelessWidget {
  const RegionWidget({
    super.key,
    required this.region,
  });

  final Region region;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      switch (region) {
        Region.us => 'assets/flags/amflag.bmp',
        Region.uk => 'assets/flags/euflag.bmp',
        Region.jp => 'assets/flags/jpflag.bmp',
        _ => 'assets/flags/naflag.bmp',
      },
      width: 100,
      height: 50,
    );
  }
}
