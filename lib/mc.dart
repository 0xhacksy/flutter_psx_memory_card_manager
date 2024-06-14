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
        final frameCount = saveData[2];
        final identifier = headerData.getRange(22, 30).toList().clearZeroes();
        final productCode = headerData.getRange(12, 22).toList().clearZeroes();
        slots.add(
          Slot(
            code: String.fromCharCodes(productCode),
            icons: [],
            palette: [],
            frameCount: getFrameCount(frameCount),
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
