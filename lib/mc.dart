import 'dart:typed_data';

import 'package:charset/charset.dart';
import 'package:unorm_dart/unorm_dart.dart';

class MC {
  MC({
    required this.slots,
    required this.data,
  });
  final Uint8List data;
  final List<Slot> slots;

  factory MC.fromBytes(Uint8List contents) {
    if (contents[0] != 0x4d || contents[1] != 0x43) {
      throw Exception('Invalid memory card');
    }
    final slots = List<Slot>.empty(growable: true);
    for (int slotNumber = 0; slotNumber < 15; slotNumber++) {
      final headerStart = 128 + (slotNumber * 128);
      final headerEnd = headerStart + 128;
      final headerData = contents.getRange(headerStart, headerEnd).toList();

      final regionBytes = headerData.getRange(0x0A, 0xC).toList().clearZeroes();

      final saveDataStart = 8192 + (slotNumber * 8192);
      final saveDataEnd = saveDataStart + 8192;
      final saveData = contents.getRange(saveDataStart, saveDataEnd).toList();

      if (regionBytes.isNotEmpty) {
        final region = regionBytes[1] << 8 | regionBytes[0];
        final name = saveData.getRange(0x4, 0x44).toList().clearZeroes();
        final frameCount = getFrameCount(saveData[2]);
        final identifier = headerData.getRange(22, 30).toList().clearZeroes();
        final productCode = headerData.getRange(12, 22).toList().clearZeroes();
        final palette = getPalette(saveData.getRange(96, 128 + 1).toList());
        final icons = getIcons(frameCount, palette, saveData);
        slots.add(
          Slot(
            code: String.fromCharCodes(productCode),
            icons: icons,
            palette: palette,
            frameCount: frameCount,
            region: region.getRegion(),
            name: parseName(name),
            identifier: String.fromCharCodes(identifier),
          ),
        );
      }
    }
    return MC(
      data: contents,
      slots: slots,
    );
  }

  bool get isValid => data[0] == 0x4d && data[1] == 0x43;
}

List<List<int>> getIcons(
    int frameCount, List<List<int>> palette, List<int> saveData) {
  List<List<int>> icons = <List<int>>[];
  for (int iconNumber = 0; iconNumber < frameCount; iconNumber++) {
    final iconData = getIconData(saveData, palette, iconNumber);
    icons.add(iconData);
  }
  return icons;
}

List<int> getIconData(
    List<int> saveData, List<List<int>> palette, int iconNumber) {
  final array = List<int>.generate(256 * 4, (index) => 0).toList();
  final offset = iconNumber * 128;
  for (int i = 0; i < 128; i++) {
    final byte = saveData[offset + 128 + i];
    final leftPixel = int.parse("00001111", radix: 2) & byte;
    final rightPixel = (int.parse("11110000", radix: 2) & byte) >>> 4;
    array[(i * 8) + 0] = palette[leftPixel][0];
    array[(i * 8) + 1] = palette[leftPixel][1];
    array[(i * 8) + 2] = palette[leftPixel][2];
    array[(i * 8) + 3] = palette[leftPixel][3];

    array[(i * 8) + 4 + 0] = palette[rightPixel][0];
    array[(i * 8) + 4 + 1] = palette[rightPixel][1];
    array[(i * 8) + 4 + 2] = palette[rightPixel][2];
    array[(i * 8) + 4 + 3] = palette[rightPixel][3];
  }
  return array;
}

String parseName(List<int> bytes) {
  List<int> title = List<int>.empty(growable: true);
  for (int currentByte = 0; currentByte < bytes.length; currentByte++) {
    final x = bytes[currentByte];
    if (currentByte % 2 == 0 && x == 0) {
      title = title.getRange(0, currentByte).toList();
    }
    title.add(x);
  }
  try {
    return nfkc(shiftJis.decode(title));
  } catch (e) {
    return String.fromCharCodes(title);
  }
}

List<List<int>> getPalette(List<int> paletteBytes) {
  List<List<int>> colors = <List<int>>[];
  for (int i = 0; i < 16; i++) {
    int position = i * 2;
    final color = paletteBytes[position] + paletteBytes[position + 1] * 256;
    var r = (int.parse('0000000000011111', radix: 2) & color);
    var g = (int.parse('0000001111100000', radix: 2) & color) >>> 5;
    var b = (int.parse('0111110000000000', radix: 2) & color) >>> 10;
    var a = color == 0 ? 0 : 255;
    r = (r * (255 / 31)).truncate();
    g = (g * (255 / 31)).truncate();
    b = (b * (255 / 31)).truncate();
    colors.add([r, g, b, a]);
  }
  return colors;
}

int getFrameCount(int value) {
  return switch (value) {
    0x11 => 1,
    0x12 => 2,
    0x13 => 3,
    _ => 0,
  };
}

class Slot {
  Slot({
    required this.icons,
    required this.frameCount,
    required this.region,
    required this.palette,
    required this.name,
    required this.identifier,
    required this.code,
  });
  final int frameCount;
  final List<List<int>> icons;
  final List<List<int>> palette;
  final Region region;
  final String name;
  final String code;
  final String identifier;
}

enum Region {
  us(0x4142),
  uk(0x4542),
  jp(0x4942),
  nr(0);

  const Region(this.value);
  final int value;
}

extension RegionExtension on int {
  Region getRegion() => Region.values
      .firstWhere((element) => element.value == this, orElse: () => Region.nr);
}

extension Zeros on List<int> {
  List<int> clearZeroes() {
    return where((value) => value != 0).toList();
  }
}
