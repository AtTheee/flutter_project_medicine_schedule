import 'dart:io';

import 'package:dory/components/dory_constants.dart';
import 'package:dory/components/dory_widgets.dart';
import 'package:dory/main.dart';
import 'package:dory/models/medicine_history.dart';
import 'package:dory/pages/add_medicine/components/bottom_submitbutton_widget.dart';
import 'package:dory/pages/bottomsheet/pick_image_bottomsheet.dart';
import 'package:dory/services/dory_file_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class AddHistoryPage extends StatefulWidget {
  const AddHistoryPage({super.key});

  @override
  State<AddHistoryPage> createState() => _AddHistoryPageState();
}

class _AddHistoryPageState extends State<AddHistoryPage> {
  String? imagePath;
  final _nameController = TextEditingController();
  DateTime selectDay = DateTime.now();
  DateTime selectTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    Future<void> selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectDay,
        firstDate: DateTime(1900),
        lastDate: DateTime(2100),
      );
      if (picked != null && picked != selectDay) {
        setState(() {
          selectDay = picked;
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // 키보드 열렸을 때 다른 곳 터치하면 닫히게
        },
        child: Padding(
          padding: pagePadding,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '복약 정보',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(
                  height: largeSpace,
                ),
                Center(
                  child: _MedicineImageButton(
                    // 4
                    changeImagePath: (String? value) {
                      imagePath = value; // 이미지 경로를 받아옴 (콜백함수로)
                    },
                  ),
                ),
                const SizedBox(
                  height: largeSpace + regularSpace,
                ),
                Text(
                  '약 이름',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextFormField(
                  controller: _nameController,
                  maxLength: 20, // 최대 입력 값
                  keyboardType:
                      TextInputType.text, // email로 하면 email입력하기 쉬운 키보드 배열
                  textInputAction:
                      TextInputAction.done, // 키보드 엔터키가 완료(done)으로 뜨게
                  style: Theme.of(context).textTheme.bodyLarge, // 입력 글자 스타일
                  decoration: InputDecoration(
                    hintText: '복용한 약 이름을 기입해주세요.',
                    hintStyle: Theme.of(context).textTheme.bodyMedium,
                    contentPadding: textFieldContentPadding, // 가로 여백
                  ),
                  onChanged: (_) {
                    // 변화 감지되면 다시 그려줘
                    setState(() {});
                  },
                ),
                const SizedBox(height: regularSpace),
                Text(
                  '복용 날짜',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: regularSpace),
                // SizedBox(
                //   height: 100,
                //   child: CupertinoDatePicker(
                //     onDateTimeChanged: (dateTime) {},
                //     mode: CupertinoDatePickerMode.date,
                //     initialDateTime: DateTime.now(),
                //   ),
                // ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        "${selectDay.toLocal().year}년  ${selectDay.toLocal().month}월  ${selectDay.toLocal().day}일",
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          selectDate(context);
                        },
                        icon: const Icon(
                          CupertinoIcons.calendar,
                          color: Colors.black54,
                        ))
                  ],
                ),

                const SizedBox(height: largeSpace),
                Text(
                  '복용 시간',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: regularSpace),
                SizedBox(
                  height: 100,
                  child: CupertinoDatePicker(
                    onDateTimeChanged: (dateTime) {
                      selectTime = dateTime;
                    },
                    mode: CupertinoDatePickerMode.time,
                    initialDateTime: DateTime.now(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomSubmitButton(
        onPressed: _nameController.text.isEmpty
            ? null
            : () {
                historyRepository.addHistory(MedicineHistory(
                    medicineId: -2,
                    alarmTime: "00:00",
                    takeTime: DateTime(selectDay.year, selectDay.month,
                        selectDay.day, selectTime.hour, selectTime.minute),
                    medicineKey: -2,
                    name: _nameController.text,
                    imagePath: imagePath));
                Navigator.pop(context, true);
              },
        text: '완료',
      ),
    );
  }
}

class _MedicineImageButton extends StatefulWidget {
  const _MedicineImageButton({required this.changeImagePath});

  final ValueChanged<String?>
      changeImagePath; // 안쪽 데이터를 바깥쪽으로 전달하기 위함 1 (다른 페이지로 이미지 경로 넘길려고)

  @override
  State<_MedicineImageButton> createState() => _MedicineImageButtonState();
}

class _MedicineImageButtonState extends State<_MedicineImageButton> {
  File? _pickImage; // 처음엔 이미지가 없으니 nullable

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 40,
      child: CupertinoButton(
        padding: _pickImage == null
            ? null
            : EdgeInsets.zero, // 카메라 아이콘일떄는 패딩을 그대로 둬서 터치부분을 늘림
        onPressed: _showBottomSheet,
        child: _pickImage == null
            ? const Icon(
                CupertinoIcons.photo_camera_solid,
                size: 30,
                color: Colors.white,
              )
            : CircleAvatar(
                foregroundImage: FileImage(_pickImage!),
                radius: 40,
              ),
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return PickImageBottomSheet(
            onPressedCamera: () => _onPressed(ImageSource.camera),
            onPressedGallery: () => _onPressed(ImageSource.gallery),
          );
        });
  }

  Future<void> _onPressed(ImageSource source) async {
    try {
      final xfile = await ImagePicker()
          .pickImage(source: source); // 선택한 이미지가 xFile객체로 반환됨
      if (xfile != null) {
        final File imageFile = File(xfile.path); // 퍼알 경로를 가져와 File객체로 생성
        final String imagePath =
            await saveImageToLocalDirectory(imageFile); // imagePath 로컬 디렉토리에 저장

        // 비동기 로직 후 상태 업데이트
        setState(() {
          _pickImage = imageFile; // 파일 객체는 _pickImage에 저장됨
          widget.changeImagePath(imagePath); // 콜백 함수를 통해 외부로 이미지 경로 전달
        });
        Navigator.maybePop(context); // 모달 바텀 시트 닫기
      }
    } catch (error) {
      // 에러 처리
      if (error is PlatformException) {
        Navigator.maybePop(context);
        showPermissionDenied(context, permission: '카메라 및 갤러리 접근');
      } else {
        // 다른 에러 처리
        print('에러: $error');
      }
    }
  }

  // void _onPressed(ImageSource source) {
  //   ImagePicker().pickImage(source: source).then((xfile) {
  //     if (xfile != null) {
  //       setState(() {
  //         _pickImage = File(xfile.path); // 이미지 경로
  //         widget.changeImageFile(_pickImage); // 2
  //       });
  //     }
  //     Navigator.maybePop(context); // 끌게 있으면 꺼줘
  //   }).onError((error, stackTrace) {
  //     // show setting 카메라, 앨범 권한인데 ios에서만 뜨나?
  //     Navigator.pop(context);
  //     showPermissionDenied(context, permission: '카메라 및 갤러리 접근');
  //   }); // 전달받은 xfile을 변수에 저장
  // }
}
