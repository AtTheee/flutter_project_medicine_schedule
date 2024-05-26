import 'package:dory/components/dory_constants.dart';
import 'package:flutter/material.dart';

class TodayEmpty extends StatelessWidget {
  const TodayEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Center(child: Text('추가된 약과 알림이 없습니다.')),
        const SizedBox(height: smallSpace),
        Text(
          '약을 추가해주세요.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}
