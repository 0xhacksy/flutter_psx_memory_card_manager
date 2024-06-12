import 'package:flutter/services.dart';
import 'package:flutter_memory_card/mc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });
  test('Loads a valid PSX Memory Card', () async {
    final contents = await rootBundle.load('assets/SLUS-00453-1.mcd');
    final mc = MC.fromBytes(contents.buffer.asUint8List());
    expect(mc.isValid, true);
  });

  test('Memory card has 1 slot', () async {
    final contents = await rootBundle.load('assets/SLUS-00453-1.mcd');
    final mc = MC.fromBytes(contents.buffer.asUint8List());
    expect(mc.slots.length, 1);
  });

  test('Memory card in first slot contains Megaman 8 Code', () async {
    final contents = await rootBundle.load('assets/SLUS-00453-1.mcd');
    final mc = MC.fromBytes(contents.buffer.asUint8List());
    expect(mc.slots.first.code, 'SLUS-00453');
  });

  test('Memory card in first slot contains Megaman 8 Region', () async {
    final contents = await rootBundle.load('assets/SLUS-00453-1.mcd');
    final mc = MC.fromBytes(contents.buffer.asUint8List());
    expect(mc.slots.first.region, Region.us);
  });

  test('Memory card in first slot contains 3 frames', () async {
    final contents = await rootBundle.load('assets/SLUS-00453-1.mcd');
    final mc = MC.fromBytes(contents.buffer.asUint8List());
    expect(mc.slots.first.frameCount, 3);
  });

  test('Memory card in first slot contains name in ascii', () async {
    final contents = await rootBundle.load('assets/SLUS-00453-1.mcd');
    final mc = MC.fromBytes(contents.buffer.asUint8List());
    expect(mc.slots.first.name, 'MEGAMAN 8');
  });
}
