import 'package:flutter/material.dart';

class CcItemStatusContentWidget extends StatelessWidget {
  final Widget item;
  final Widget description;

  const CcItemStatusContentWidget({
    required this.item,
    required this.description,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          item,
          const SizedBox(height: 8.0),
          description,
        ],
      ),
    );
  }
}
