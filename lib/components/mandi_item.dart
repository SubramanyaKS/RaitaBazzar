import 'package:flutter/material.dart';
import 'package:raitabazzar/utils/constant.dart';

class MandiItem extends StatelessWidget {
  final String crop;
  final String rate;
  final bool isUp;

  const MandiItem({super.key, 
    required this.crop,
    required this.rate,
    required this.isUp,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(crop, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              rate,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isUp ? AppConstants.primaryGreen : Colors.red,
              ),
            ),
            Icon(
              isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              color: isUp ? AppConstants.primaryGreen : Colors.red,
              size: 16,
            ),
          ],
        ),
      ],
    );
  }
}