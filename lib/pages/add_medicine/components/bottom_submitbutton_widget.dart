import 'package:dory/components/dory_constants.dart';
import 'package:flutter/material.dart';

// page 공통 UI

class BottomSubmitButton extends StatelessWidget {
  const BottomSubmitButton({super.key, this.onPressed, required this.text});

  final VoidCallback? onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // 원래 있는? 차지하고 있는 영역을 침범하지 않는 선에서 그려짐
      child: Padding(
        padding: submitButtonBoxPadding,
        child: SizedBox(
          height: submitButtonHeight, // 버튼 크기 (높이)
          child: ElevatedButton(
            // onPressed: _nameController.text.isEmpty ? null : _onAddAlarmPage,
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              textStyle: Theme.of(context).textTheme.titleMedium,
            ), // 버튼 자체적으로 가지고 있는 textstyle이 있기 때문에 그 스타일에서 크기만 바꾸려면 이렇게 해야함
            child: Text(text),
          ),
        ),
      ),
    );
  }
}
