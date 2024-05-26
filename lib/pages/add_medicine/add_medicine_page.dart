import 'dart:io';

import 'package:dory/components/dory_widgets.dart';
import 'package:dory/main.dart';
import 'package:dory/models/medicine.dart';
import 'package:flutter/services.dart';

import '../../components/dory_constants.dart';
import 'package:dory/components/dory_page_route.dart';
import 'package:dory/pages/add_medicine/add_alarm_page.dart';
import 'package:dory/pages/add_medicine/components/bottom_submitbutton_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../bottomsheet/pick_image_bottomsheet.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key, this.updateMedicineId = -1});

  final int updateMedicineId; // 약 정보 수정을 위한 id 값 (새로운 약 추가시 디폴트는 -1로)

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  late TextEditingController _nameController; // 나중에 초기화 할거야
  late TextEditingController _memoController;
  File? _medicineimage; // 3 (이미지 버튼을 눌러서 가져온 이미지 경로를 받을 변수)

  // 약 정보 수정하기를 위한 코드
  bool get _isUpdate => widget.updateMedicineId != -1;
  Medicine get _updateMedicine => medicineRepository.medicineBox.values
      .singleWhere((medicine) => medicine.id == widget.updateMedicineId);

  @override
  void initState() {
    super.initState();

    if (_isUpdate) {
      _nameController = TextEditingController(text: _updateMedicine.name);
      _memoController = TextEditingController(text: _updateMedicine.memo);
      if (_updateMedicine.imagePath != null) {
        _medicineimage = File(_updateMedicine.imagePath!);
      }
    } else {
      _nameController = TextEditingController();
      _memoController = TextEditingController();
    }
  }

  @override
  void dispose() {
    // 컨트롤러 해제 시 할당된 메모리 해제
    _nameController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  '약 정보',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(
                  height: largeSpace,
                ),
                Center(
                  child: _MedicineImageButton(
                    updateImage: _medicineimage,
                    // 4
                    changeImageFile: (File? value) {
                      _medicineimage =
                          value; // 변경된 이미지 경로를 받아옴(전달 x), 변경될때마다 호출
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
                    hintText: '복용할 약 이름을 기입해주세요.',
                    hintStyle: Theme.of(context).textTheme.bodyMedium,
                    contentPadding: textFieldContentPadding, // 가로 여백
                  ),
                  onChanged: (_) {
                    // 변화 감지되면 다시 그려줘
                    setState(() {});
                  },
                ),
                const SizedBox(height: largeSpace),
                Text(
                  '약 메모',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: regularSpace),
                TextFormField(
                  controller: _memoController,
                  minLines: 6,
                  maxLines: 6,
                  maxLength: null, // 최대 입력 값
                  keyboardType: TextInputType.multiline,
                  textInputAction:
                      TextInputAction.done, // 키보드 엔터키가 완료(done)으로 뜨게
                  style: Theme.of(context).textTheme.bodyLarge, // 입력 글자 스타일
                  decoration: InputDecoration(
                    hintText: '복용할 약의 추가 정보를 기입해주세요.',
                    hintStyle: Theme.of(context).textTheme.bodyMedium,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10), // 가로 여백
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) {
                    // 변화 감지되면 다시 그려줘
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomSubmitButton(
        onPressed: _nameController.text.isEmpty ? null : _onAddAlarmPage,
        text: '다음',
      ),
    );
  }

  void _onAddAlarmPage() {
    Navigator.push(
        context,
        FadePageRoute(
          page: AddAlarmPage(
            medicineName: _nameController.text,
            medicineImage: _medicineimage,
            medicineMemo: _memoController.text,
            updateMedicineId: widget.updateMedicineId,
          ),
        ));
  }
}

// 이미지 가져오기
// 갤러리,카메라 연결하려면 image_picker add dependency (yaml 파일에) + info.plist에 ios 권한 추가

class _MedicineImageButton extends StatefulWidget {
  const _MedicineImageButton({required this.changeImageFile, this.updateImage});

  final ValueChanged<File?>
      changeImageFile; // 안쪽 데이터를 바깥쪽으로 전달하기 위함 1 (다른 페이지로 이미지 경로 넘길려고)
  final File? updateImage;

  @override
  State<_MedicineImageButton> createState() => _MedicineImageButtonState();
}

class _MedicineImageButtonState extends State<_MedicineImageButton> {
  File? _pickImage; // 처음엔 이미지가 없으니 nullable

  @override
  void initState() {
    super.initState();
    _pickImage = widget.updateImage; // 부모 위젯이 가진 updateImage로 초기화
  }

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
      final xfile = await ImagePicker().pickImage(source: source);
      if (xfile != null) {
        setState(() {
          _pickImage = File(xfile.path); // 이미지 경로
          widget.changeImageFile(_pickImage); // 2
        });
        Navigator.maybePop(context); // 끌게 있으면 꺼줘
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
