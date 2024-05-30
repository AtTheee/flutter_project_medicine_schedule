import 'dart:io';

import 'package:dory/components/dory_constants.dart';
import 'package:dory/components/dory_widgets.dart';
import 'package:dory/main.dart';
import 'package:dory/models/medicine.dart';
import 'package:dory/models/medicine_alarmtime.dart';
import 'package:dory/services/add_medicine_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/dory_file_service.dart';
import '../bottomsheet/time_setting_bottomsheet.dart';
import 'components/bottom_submitbutton_widget.dart';

// 약 정보 입력하고 다음 버튼 누르면 나오는 페이지

// ignore: must_be_immutable
class AddAlarmPage extends StatefulWidget {
  AddAlarmPage(
      {super.key,
      this.medicineImage,
      required this.medicineName,
      this.medicineMemo,
      required this.updateMedicineId}) {
    service = AddMedicineService(updateMedicineId); // 수정하기를 위한 생성자
  }

  final File? medicineImage;
  final String medicineName;
  final String? medicineMemo;
  final int updateMedicineId;

  late AddMedicineService // 알람 추가 기능
      service;
  @override
  State<AddAlarmPage> createState() => _AddAlarmPageState();
}

class _AddAlarmPageState extends State<AddAlarmPage> {
  // nonnullable 값인데 초기화가 안돼있음(생성자에서 받음 = late 달아줘야함)
  List<bool> isSelected = List.generate(7, (index) => false);
  bool isSwitched = true;
  List<int> selectedWeeks = [];
  List<int> originalSelectedWeekdays = [];
  List<Color> color = List.generate(7, (index) => Colors.grey[200]!);
  final isVisibleNotifier = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    // 여기에서 _updateMedicine 초기화 또는 설정 로직이 필요합니다.
    // 예를 들어, 생성자를 통해 전달받거나, 상위 위젯/페이지로부터 정보를 전달받는 로직 등
    // 초기화 후, originalSelectedWeekdays를 설정할 수 있습니다.
    if (widget.updateMedicineId != -1) {
      originalSelectedWeekdays = _updateMedicine.weekdays;
      if (originalSelectedWeekdays.isNotEmpty) {
        for (int i = 0; i < 7; i++) {
          isSelected[i] = false;
          color[i] = Colors.white;
        }
        selectedWeeks.addAll(_updateMedicine.weekdays);
        isSwitched = false;
        for (var day in originalSelectedWeekdays) {
          isSelected[day - 1] = true;
          color[day - 1] = Colors.grey[200]!;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '언제 알려드릴까요?',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(
              height: largeSpace,
            ),
            Expanded(
              child: AnimatedBuilder(
                animation:
                    widget.service, // Listner를 읽고있는 아이..? 화면 변화 감지하는 아이인가
                builder: (context, _) {
                  return ListView(
                    children: alarmWidgets,
                  );
                },
              ),
            ),
            // Expanede = 나머지 영역 모두 그림 / ListView() 스크롤 가능한 위젯
            ValueListenableBuilder<bool>(
                valueListenable: isVisibleNotifier,
                builder: (context, isVisible, _) {
                  return Visibility(
                    visible: isVisible,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text('매일'),
                            Container(
                              padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                              child: Switch(
                                  value: isSwitched,
                                  onChanged: (value) {
                                    setState(() {
                                      isSwitched = value;
                                      if (isSwitched) {
                                        color = List.generate(
                                            7, (index) => Colors.grey[200]!);
                                        selectedWeeks.clear();
                                        isSelected =
                                            List.generate(7, (index) => false);
                                      } else {
                                        color = List.generate(
                                            7, (index) => Colors.white);
                                      }
                                    });
                                  }),
                            ),
                          ],
                        ),
                        Center(
                          child: ToggleButtons(
                            isSelected: isSelected,
                            onPressed: (int index) {
                              setState(() {
                                // 요일 선택 상태 토글
                                isSelected[index] = !isSelected[index];

                                // 선택된 요일이 하나라도 있는지 확인
                                bool anySelected = isSelected.contains(true);

                                if (anySelected) {
                                  isSwitched =
                                      false; // 사용자가 요일을 선택했으므로 isSwitched를 false로 설정
                                  for (int i = 0; i < isSelected.length; i++) {
                                    // 모든 요일을 확인하며 선택된 요일은 grey, 선택되지 않은 요일은 white로 설정
                                    color[i] = isSelected[i]
                                        ? Colors.grey[200]!
                                        : Colors.white;
                                  }
                                } else {
                                  isSwitched =
                                      true; // 모든 선택이 해제되면 다시 isSwitched를 true로 설정
                                  for (int i = 0; i < isSelected.length; i++) {
                                    // 모든 요일을 grey로 설정
                                    color[i] = Colors.grey[200]!;
                                  }
                                }

                                // 선택된 요일 관리
                                if (isSelected[index]) {
                                  selectedWeeks.add(index + 1);
                                } else {
                                  selectedWeeks.remove(index + 1);
                                }

                                // 모든 요일이 선택되었는지 확인하여 isSwitch를 업데이트
                                if (isSelected.every((element) => element)) {
                                  isSwitched =
                                      true; // 모든 요일이 선택되었다면, isSwitch를 true로 설정
                                  selectedWeeks
                                      .clear(); // 모든 요일이 선택된 상태이므로, selectedWeeks를 클리어
                                  // 모든 요일을 다시 선택된 색상으로 변경할 수 있으나,
                                  // 이 경우 모든 요일이 이미 grey로 설정되어 있으므로, 별도로 설정할 필요가 없습니다.
                                  for (int i = 0; i < isSelected.length; i++) {
                                    isSelected[i] = false; // 모든 요일을 선택 상태로 설정
                                  }
                                }
                                // print(selectedWeeks);
                              });
                            },
                            borderColor: Colors.white, // 선택되지 않은 항목의 테두리 색상
                            fillColor: Colors.white,
                            selectedBorderColor: Colors.white,
                            splashColor: Colors.white,
                            children: [
                              dayButton('월', color[0]),
                              dayButton('화', color[1]),
                              dayButton('수', color[2]),
                              dayButton('목', color[3]),
                              dayButton('금', color[4]),
                              dayButton('토', color[5]),
                              dayButton('일', color[6]),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                })
          ],
        ),
      ),
      bottomNavigationBar: BottomSubmitButton(
        onPressed: () async {
          final isUpdate = widget.updateMedicineId != -1;
          isUpdate
              ? await _onUpdateMedicine(context)
              : await _onAddMedicine(context);
        },
        text: '완료',
      ),
    );
  }

  Container dayButton(String day, Color backgroundColor) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle, // 원 모양의 테두리
        border: Border.all(
          color: Colors.white, // 테두리 색상 설정
          width: 2.0, // 테두리 너비 설정
        ),
      ),
      child: CircleAvatar(
        backgroundColor: backgroundColor,
        child: Text(day),
      ),
    );
  }

  Future<void> _onUpdateMedicine(BuildContext context) async {
    String? imageFilePath = _updateMedicine.imagePath;
    if (_updateMedicine.imagePath != widget.medicineImage?.path) {
      // 2-1. delete previous image
      if (_updateMedicine.imagePath != null) {
        deleteImage(_updateMedicine.imagePath!);
      }
      // 2-2. image save (local dir)
      if (widget.medicineImage != null) {
        imageFilePath = await saveImageToLocalDirectory(widget.medicineImage!);
      }
    }

    // 1-1 delete previous alarm
    for (var alarm in _updateMedicine.alarms) {
      if (originalSelectedWeekdays.isEmpty) {
        // 매일 알람인 경우: 기존 매일 알람 ID로 모든 알람 삭제
        String dailyAlarmId = notification.alarmId(_updateMedicine.id, alarm);
        await notification.deleteAlarm(dailyAlarmId);
      } else {
        // 요일별 알람인 경우: 각 요일별 알람 ID로 삭제
        for (var day in originalSelectedWeekdays) {
          String alarmId = notification.alarmId(_updateMedicine.id, alarm, day);
          await notification.deleteAlarm(alarmId);
        }
      }
    }

    originalSelectedWeekdays = _updateMedicine.weekdays;

    final alarmTimes = alarmTimeRepository.alarmTimeBox.values.toList();

    Map<String, bool> checkedStatusMap = {};

    for (var alarmTime in alarmTimes) {
      if (alarmTime.medicineKey == _updateMedicine.key) {
        checkedStatusMap[alarmTime.alarmTIme] = alarmTime.checked;

        // 알람을 수정하니까 그 전에 있던 List들이 달력 밑에 없어짐. 그걸 보완하려고 조건문 추가해봄
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final addDate = DateTime(alarmTime.addDate.year,
            alarmTime.addDate.month, alarmTime.addDate.day);

        alarmTime.deleteDate =
            today; // 일단 수정하면 다 삭제하고 알람을 새로 다 넣으니까 deleteDate는 넣어줘야함.
        await alarmTime.save();

        if (addDate == today) {
          // 오늘 추가한 알람만 저장소에서 지워서 전날 리스트에는 그대로 나오게
          alarmTimeRepository.deleteAlarmTime(alarmTime.key);
        }
      }
    }

    // 3. update medicine model (local DB, hive)
    final medicine = Medicine(
        id: widget.updateMedicineId,
        name: widget.medicineName,
        imagePath: imageFilePath,
        alarms: widget.service.alarms.toList(),
        weekdays: selectedWeeks,
        memo: widget.medicineMemo);
    medicineRepository.updateMedicine(
        key: _updateMedicine.key, medicine: medicine);

    List<Future> futures = [];

    // 1-2. alarm + //
    for (var alarm in widget.service.alarms) {
      alarmTimeRepository.addAlramTime(MedicineAlarmTime(
          alarmTIme: alarm,
          medicineKey: medicine.key,
          name: widget.medicineName,
          imagePath: imageFilePath,
          checked: checkedStatusMap[alarm] ?? false,
          weekdays: medicine.weekdays,
          checkedDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
          addDate: DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day)));

      futures.add(notification.addNotification(
          alarmTimeStr: alarm,
          title: '$alarm 약 먹을 시간이에요!',
          body: '${widget.medicineName} 복약했다고 알려주세요!',
          medicineId: widget.updateMedicineId,
          notificationDays: selectedWeeks));
    }
    // 모든 비동기 작업이 완료될 때까지 기다림
    List results = await Future.wait(futures);

    // 모든 결과를 확인하여 하나라도 실패한 경우 권한 문제로 간주
    if (results.any((r) => !r)) {
      // mounted 검사 추가
      if (!mounted) return;
      return showPermissionDenied(context, permission: '알림');
    }

// 모든 작업이 성공적으로 완료되면 화면 업데이트
// mounted 검사 추가
    if (mounted) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  Medicine get _updateMedicine => medicineRepository.medicineBox.values
      .singleWhere((medicine) => medicine.id == widget.updateMedicineId);

  Future<void> _onAddMedicine(BuildContext context) async {
    // 2. image save (local dir)
    String? imageFilePath;
    if (widget.medicineImage != null) {
      imageFilePath = await saveImageToLocalDirectory(widget.medicineImage!);
    }

    // 3. add medicine model (local DB, hive)
    final medicine = Medicine(
        id: medicineRepository.newId,
        name: widget.medicineName,
        imagePath: imageFilePath,
        alarms: widget.service.alarms.toList(),
        weekdays: selectedWeeks,
        memo: widget.medicineMemo);
    medicineRepository.addMedicine(medicine);

    // 비동기 작업들을 기다리기 위한 리스트
    List<Future> futures = [];

    // 1. alarm + //
    if (!mounted) return;
    // if (widget.service.alarms.isEmpty) {
    //   return showPermissionDenied(context, permission: '');
    // }
    for (var alarm in widget.service.alarms) {
      alarmTimeRepository.addAlramTime(MedicineAlarmTime(
          alarmTIme: alarm,
          medicineKey: medicine.key,
          name: widget.medicineName,
          imagePath: imageFilePath,
          weekdays: medicine.weekdays,
          addDate: DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day)));

      futures.add(notification.addNotification(
          alarmTimeStr: alarm,
          title: '$alarm 약 먹을 시간이에요!',
          body: '${widget.medicineName} 복약했다고 알려주세요!',
          medicineId: medicine.id,
          notificationDays: selectedWeeks)); // id 부여
    }

    // 모든 비동기 작업이 완료될 때까지 기다림
    List results = await Future.wait(futures);

// 모든 결과를 확인하여 하나라도 실패한 경우 권한 문제로 간주
    if (results.any((r) => !r)) {
      // mounted 검사 추가
      if (!mounted) return;
      return showPermissionDenied(context, permission: '알림');
    }

// 모든 작업이 성공적으로 완료되면 화면 업데이트
// mounted 검사 추가
    if (mounted) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  List<Widget> get alarmWidgets {
    final children = <Widget>[];
    children.addAll(
      widget.service.alarms.map((alarmTime) => AlarmBox(
            // 각 알람시간을 AlarmBox에 넘겨줌
            time: alarmTime,
            service: widget.service,
            isVisibleNotifier: isVisibleNotifier,
          )),
    );
    children.add(AddAlarmButton(
      service: widget.service,
      isVisibleNotifier: isVisibleNotifier,
    ));
    return children;
  }
}

// 추가된 알람
class AlarmBox extends StatelessWidget {
  const AlarmBox({
    super.key,
    required this.time,
    required this.service,
    required this.isVisibleNotifier,
  });

  final String time;

  final AddMedicineService service;

  final ValueNotifier<bool> isVisibleNotifier;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: IconButton(
            onPressed: () {
              service.removeAlarm(time);
              if (service.alarms.isEmpty) {
                isVisibleNotifier.value = false;
              }
            },
            icon: const Icon(CupertinoIcons.minus_circle),
          ),
        ),
        Expanded(
          flex: 4,
          child: TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.titleSmall,
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return TimeSettingBottomSheet(
                    initialTime: time,
                  );
                },
              ).then((value) {
                if (value == null || value is! DateTime) return;
                service.setAlarm(
                    prevTime: time,
                    setTime: value); // 이전에 설정된 알림 시간은 삭제하고 새로 설정한 알림 시간으로 추가
              });
            },
            child: Text(time),
          ),
        ),
      ],
    );
  }
}

// 알람 추가하기
class AddAlarmButton extends StatelessWidget {
  const AddAlarmButton({
    super.key,
    required this.service,
    required this.isVisibleNotifier,
  });

  final AddMedicineService service;

  final ValueNotifier<bool> isVisibleNotifier;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
        textStyle: Theme.of(context).textTheme.titleMedium,
      ),
      onPressed: () {
        service.addNowAlarm();
        if (service.alarms.isNotEmpty) {
          isVisibleNotifier.value = true;
        }
      },
      child: const Row(
        children: [
          Expanded(
            flex: 1,
            child: Icon(CupertinoIcons.plus_circle_fill),
          ),
          Expanded(
            flex: 4,
            child: Center(
              child: Text('복용시간 추가'),
            ),
          ),
        ],
      ),
    );
  }
}
