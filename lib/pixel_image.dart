import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class PixelImage extends StatelessWidget {
  const PixelImage({
    super.key,
    required this.pixels,
    this.width,
    this.height,
  });
  final double? width;
  final double? height;
  final List<int> pixels;

  @override
  Widget build(BuildContext context) {
    return Image(
      width: width,
      height: height,
      fit: BoxFit.fill,
      image: PixelImageProvider(pixels),
    );
  }
}

class PixelImageProvider extends ImageProvider<PixelImageProvider> {
  PixelImageProvider(this.pixels);
  final List<int> pixels;

  @override
  Future<PixelImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<PixelImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadImage(
      PixelImageProvider key, ImageDecoderCallback decode) {
    return OneFrameImageStreamCompleter(Future(() async {
      final buffer =
          await ImmutableBuffer.fromUint8List(Uint8List.fromList(pixels));
      final codec = await ImageDescriptor.raw(
        buffer,
        width: 16,
        height: 16,
        pixelFormat: PixelFormat.rgba8888,
      ).instantiateCodec();
      final frame = await codec.getNextFrame();
      return ImageInfo(
        image: frame.image,
      );
    }));
  }
}
