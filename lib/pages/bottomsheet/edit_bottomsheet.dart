import 'package:flutter/material.dart';

import '../../components/dory_widgets.dart';

class EditBottomSheet extends StatelessWidget {
  const EditBottomSheet(
      {super.key,
      required this.onPressedSort,
      required this.onPressedDeleteAllMedicine});

  final VoidCallback onPressedSort;
  final VoidCallback onPressedDeleteAllMedicine;

  @override
  Widget build(BuildContext context) {
    return BottomSheetBody(
      children: [
        TextButton(
          onPressed: onPressedSort,
          child: const Text('정렬'),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          onPressed: onPressedDeleteAllMedicine,
          child: const Text('전체 삭제'),
        ),
      ],
    );
  }
}
