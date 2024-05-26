import 'package:flutter/material.dart';

import '../../components/dory_widgets.dart';

class SortBottomSheet extends StatelessWidget {
  const SortBottomSheet(
      {super.key,
      required this.onPressedAlramTimeSort,
      required this.onPressedAlramCurrentTimeSort,
      required this.onPressedMedicineNameSort});

  final VoidCallback onPressedAlramTimeSort;
  final VoidCallback onPressedAlramCurrentTimeSort;
  final VoidCallback onPressedMedicineNameSort;

  @override
  Widget build(BuildContext context) {
    return BottomSheetBody(
      children: [
        TextButton(
          onPressed: onPressedAlramTimeSort,
          child: const Text('등록순(기본)'),
        ),
        TextButton(
          onPressed: onPressedAlramCurrentTimeSort,
          child: const Text('최신순'),
        ),
        TextButton(
          onPressed: onPressedMedicineNameSort,
          child: const Text('이름순'),
        ),
      ],
    );
  }
}
