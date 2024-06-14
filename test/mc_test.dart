import 'package:flutter/services.dart';
import 'package:flutter_memory_card/mc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Test Valid Memory Card', () {
    late ByteData contents;
    late MC mc;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      contents = await rootBundle.load('test_assets/mc/SLUS-00453-1.mcd');
      mc = MC.fromBytes(contents.buffer.asUint8List());
    });

    test('Loads a valid PSX Memory Card', () {
      expect(mc.isValid, true);
    });

    test('Memory card has 1 slot', () async {
      expect(mc.slots.length, 1);
    });

    test('Memory card in first slot contains Megaman 8 Code', () async {
      expect(mc.slots.first.code, 'SLUS-00453');
    });
    test('Memory card in first slot contains Megaman 8 Identifier', () async {
      expect(mc.slots.first.identifier, '');
    });

    test('Memory card in first slot contains Megaman 8 Region', () async {
      expect(mc.slots.first.region, Region.us);
    });

    test('Memory card in first slot contains 3 frames', () async {
      expect(mc.slots.first.frameCount, 3);
    });

    test('Memory card in first slot contains name in ascii', () async {
      expect(mc.slots.first.name, 'MEGAMAN 8');
    });
  });
}
