import 'package:flutter/material.dart';

class OptionButton extends StatelessWidget {
  const OptionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.extent(
      shrinkWrap: true,
      maxCrossAxisExtent: 120, // Max width of each tile
      children: List.generate(20, (index) {
        return Center(
          child: Text('Item $index'),
        );
      }),
    );
  }
}
