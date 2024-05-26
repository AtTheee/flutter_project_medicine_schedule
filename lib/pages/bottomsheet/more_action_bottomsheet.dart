import 'package:flutter/material.dart';

import '../../components/dory_widgets.dart';

class MoreActionBottomSheet extends StatelessWidget {
  const MoreActionBottomSheet(
      {super.key,
      required this.onPressedModify,
      required this.onPressedDeleteOnlyMedicine,
      // required this.onPressedDetailView,
      required this.onPressedDisableMedicine,
      this.disable});

  final VoidCallback onPressedModify;
  final VoidCallback onPressedDeleteOnlyMedicine;
  // final VoidCallback onPressedDetailView;
  final VoidCallback onPressedDisableMedicine;
  final bool? disable;

  @override
  Widget build(BuildContext context) {
    return BottomSheetBody(
      children: [
        // TextButton(
        //   onPressed: onPressedDetailView,
        //   child: const Text('자세히 보기'),
        // ),
        TextButton(
          onPressed: onPressedModify,
          child: const Text('약 정보&수정'),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.black),
          onPressed: onPressedDisableMedicine,
          child: Text(disable ?? false ? '알림 활성화' : '알림 비활성화'),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          onPressed: onPressedDeleteOnlyMedicine,
          child: const Text('약 정보 삭제'),
        ),
      ],
    );
  }
}
