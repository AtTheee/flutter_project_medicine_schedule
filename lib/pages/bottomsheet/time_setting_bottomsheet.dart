// 시간 클릭시
// ignore: must_be_immutable // stless로 만들었는데 const가 붙지않 setDateTime이 변경될 여지가 있어서 경고 무시해줌
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../components/dory_colors.dart';
import '../../components/dory_constants.dart';
import '../../components/dory_widgets.dart';

class TimeSettingBottomSheet extends StatelessWidget {
  const TimeSettingBottomSheet({
    super.key,
    required this.initialTime, // 초기화 시간(알람 시간)
    this.submitTitle = '선택',
    this.bottomWidget,
  });

  final String initialTime;
  final String submitTitle;
  final Widget? bottomWidget;

  @override
  Widget build(BuildContext context) {
    final initialDateTimeData =
        DateFormat('HH:mm').parse(initialTime); // String -> Date
    final now = DateTime.now();
    final initialDateTime = DateTime(now.year, now.month, now.day,
        initialDateTimeData.hour, initialDateTimeData.minute);
    DateTime setDateTime = initialDateTime; // 초기값이 없으니 nullable한 변수 설정

    return BottomSheetBody(
      children: [
        SizedBox(
          height: 200, // 타임피커는 사이즈 지정 필수
          child: CupertinoDatePicker(
            onDateTimeChanged: (dateTime) {
              setDateTime = dateTime; // 데이터 피커에서 선택한 시간
            },
            mode: CupertinoDatePickerMode.time,
            initialDateTime:
                setDateTime, // 현재시간 또는 설정된 시간 setDateTime으로 하면 되는거 아닌가? 왜 initialDateTime으로 해야되지?
          ),
        ),
        const SizedBox(
          height: regularSpace,
        ),
        const SizedBox(height: smallSpace),
        if (bottomWidget != null) bottomWidget!,
        const SizedBox(height: smallSpace),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: submitButtonHeight, // 버튼 높이
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.titleMedium,
                    backgroundColor: Colors.white, // 버튼 컬러
                    foregroundColor: DoryColors.primaryColor, // 버튼 글 컬러
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소'),
                ),
              ),
            ),
            const SizedBox(
              width: smallSpace,
            ),
            Expanded(
              child: SizedBox(
                height: submitButtonHeight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.titleMedium,
                  ),
                  onPressed: () {
                    Navigator.pop(context,
                        setDateTime); // pop 할때 데이터 넘김(선택한 알림시간) // 현재 화면을 닫고 이전화면으로 데이터 전달
                  },
                  child: Text(submitTitle),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
