import 'package:flutter/material.dart';
import 'package:flutter_memory_card/custom_animated_icon.dart';
import 'package:flutter_memory_card/mc.dart';
import 'package:flutter_memory_card/region_widget.dart';

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
          color: Colors.black,
          width: 64,
          height: 64,
          child: CustomAnimatedIcon(
            icons: slot.icons,
          ),
        ),
        /* Container(
          height: 5,
          width: 5,
          color: Colors.red,
        ),*/
        RegionWidget(region: slot.region),
        Text(slot.name),
        Text(slot.identifier),
        Text(slot.code),
      ],
    );
  }
}
