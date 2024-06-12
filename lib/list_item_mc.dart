import 'package:flutter/material.dart';
import 'package:flutter_memory_card/mc.dart';

class ListItemMCSlot extends StatelessWidget {
  const ListItemMCSlot({
    super.key,
    required this.slot,
  });
  final Slot slot;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          height: 5,
          width: 5,
          color: Colors.red,
        ),
        Text(slot.region.toString()),
        Text(slot.name),
        Text(slot.identifier),
        Text(slot.code),
      ],
    );
  }
}
