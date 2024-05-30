import 'dart:io';

import 'package:dory/components/dory_constants.dart';
import 'package:dory/components/dory_page_route.dart';
import 'package:dory/main.dart';
import 'package:dory/models/medicine_alarmtime.dart';
import 'package:dory/models/medicine_history.dart';
import 'package:dory/pages/add_medicine/add_medicine_page.dart';
import 'package:dory/pages/bottomsheet/edit_bottomsheet.dart';
import 'package:dory/pages/bottomsheet/more_action_bottomsheet.dart';
import 'package:dory/pages/bottomsheet/sort_bottomsheet.dart';
import 'package:dory/pages/today/image_detail_page.dart';
import 'package:dory/pages/today/today_empty_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/medicine.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TodayPage extends StatefulWidget {
  // final List<String> medicineIds = [];
  const TodayPage({super.key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

String sortOption = "time";
Map<int, bool> expandedState = {}; // expensionTile 각 화살표 컨트롤

class _TodayPageState extends State<TodayPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: textFieldContentPadding,
              child:
                  Text('약알림', style: Theme.of(context).textTheme.headlineSmall),
            ),
            Row(
              children: [
                IconButton(
                  alignment: Alignment.centerLeft,
                  icon: const Icon(
                    CupertinoIcons.add,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddPage(),
                      ),
                    );
                  },
                ),
                IconButton(
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                    icon: const Icon(
                      CupertinoIcons.gear,
                      color: Colors.black54,
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (context) => EditBottomSheet(
                                onPressedSort: () {
                                  Navigator.pop(context);
                                  showModalBottomSheet(
                                      context: context,
                                      builder: (context) => SortBottomSheet(
                                              onPressedAlramTimeSort: () {
                                            sortOption = "time";
                                            Navigator.pop(context);
                                            setState(() {});
                                          }, onPressedAlramCurrentTimeSort: () {
                                            sortOption = "currentTime";
                                            Navigator.pop(context);
                                            setState(() {});
                                          }, onPressedMedicineNameSort: () {
                                            sortOption = "name";
                                            Navigator.pop(context);
                                            setState(() {});
                                          }));
                                },
                                onPressedDeleteAllMedicine: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          title: const Text(
                                            "약 정보를 삭제하시겠습니까?",
                                            style: TextStyle(fontSize: 15),
                                          ),
                                          content: const Text(
                                            "복약 기록은 삭제되지 않습니다.",
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12),
                                          ),
                                          actions: [
                                            TextButton(
                                                onPressed: () {
                                                  deleteAllMedicine(context);
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text(
                                                  "확인",
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                )),
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text("취소")),
                                          ],
                                        );
                                      });
                                },
                              ));
                    }),
              ],
            ),
          ],
        ),
        const SizedBox(height: smallSpace),
        const Divider(height: 1, thickness: 1.0),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: medicineRepository.medicineBox
                .listenable(), // DB 변화 감지(를 기반으로 List가 그려짐)
            builder: _builderMedicineListView,
          ),
        ),
      ],
    );
  }

  Widget _builderMedicineListView(context, Box<Medicine> box, _) {
    final medicines = box.values.toList(); // 약 정보가 담긴 리스트

    if (sortOption == "time") {
      medicines.sort(((a, b) => a.id.compareTo(b.id)));
    } else if (sortOption == "currentTime") {
      medicines.sort((a, b) => b.id.compareTo(a.id));
    } else if (sortOption == "name") {
      medicines.sort((a, b) => a.name.compareTo(b.name));
    }

    if (medicines.isEmpty) {
      return const TodayEmpty();
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: smallSpace),
              separatorBuilder: (context, index) {
                return const Divider(height: 20); // 간격 구분선
              },
              itemCount: medicines.length,
              itemBuilder: (context, index) {
                return _buildListTile(medicines[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(Medicine medicine) {
    bool isExpanded = expandedState[medicine.key] ?? true; // 확장 화살표 아이콘 상태
    final medicineAlramTime = <MedicineAlarmTime>[]; // 특정 약의 모든 알람
    List<MedicineAlarmTime> allAlramTimeList =
        alarmTimeRepository.alarmTimeBox.values.toList();
    Color disabledStateTextColor = (medicine.disable == true ||
            (medicine.weekdays.isNotEmpty &&
                !medicine.weekdays.contains(DateTime.now().weekday)))
        ? Colors.grey
        : Colors.black;
    final alramId = <String>[];

    for (var alarm in allAlramTimeList) {
      if (medicine.key == alarm.medicineKey && alarm.deleteDate == null) {
        // 특정 약에 대한
        //
        medicineAlramTime.add(alarm);
        if (medicine.weekdays.isEmpty) {
          alramId.add(notification.alarmId(medicine.id, alarm.alarmTIme));
        } else {
          for (var day in medicine.weekdays) {
            alramId
                .add(notification.alarmId(medicine.id, alarm.alarmTIme, day));
          }
        }
      }
    }

    medicineAlramTime
        .sort((a, b) => a.alarmTIme.compareTo(b.alarmTIme)); // 알람 시간 순으로 정렬

    return ValueListenableBuilder(
        valueListenable: historyRepository.historyBox
            .listenable(), // historyRepository 변화 감지해서 다시그림
        builder: (context, Box<MedicineHistory> historyBox, _) {
          return Card(
            shape: RoundedRectangleBorder(
              // RoundedRectangleBorder을 사용하여 사각형 테두리 정의
              borderRadius: BorderRadius.circular(10), // 사각형이므로, 반경을 0으로 설정
              side: const BorderSide(
                color: Colors.black38, // 테두리 색상
                width: 1.0, // 테두리 두께
              ),
            ),
            child: Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                collapsedBackgroundColor: Colors.grey[50],
                // backgroundColor: Colors.grey[50],
                initiallyExpanded: true,
                title: Row(
                  children: [
                    CupertinoButton(
                        onPressed: medicine.imagePath == null
                            ? null
                            : () {
                                Navigator.push(
                                    context,
                                    FadePageRoute(
                                        page: ImageDetailPage(
                                      imagePath: medicine.imagePath!,
                                    )));
                              },
                        child: CircleAvatar(
                            radius: 20,
                            foregroundImage: medicine.imagePath == null
                                ? null
                                : FileImage(File(medicine.imagePath!)))),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medicine.name,
                          style: TextStyle(color: disabledStateTextColor),
                        ),
                        if (medicine.disable == true) ...{
                          const Text(
                            '비활성화된 알림',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 12,
                            ),
                          ),
                        } else ...{
                          Text(
                            weekdaysToString(medicine),
                            style: TextStyle(
                              color: disabledStateTextColor,
                              fontSize: 12,
                            ),
                          )
                        }
                      ],
                    ),
                  ],
                ),
                onExpansionChanged: (bool expanded) {
                  setState(() => expandedState[medicine.key] = expanded);
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min, // Row의 크기를 자식들의 크기에 맞춤
                  children: [
                    // 화살표 아이콘
                    Icon(
                      isExpanded
                          ? Icons.expand_less
                          : Icons.expand_more, // 확장 상태에 따라 아이콘 변경
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (context) => MoreActionBottomSheet(
                                  disable: medicine.disable,
                                  // onPressedDetailView: () {},
                                  onPressedModify: () {
                                    Navigator.push(
                                      context,
                                      FadePageRoute(
                                          page: AddPage(
                                              updateMedicineId: medicine.id)),
                                    ).then((_) {
                                      setState(() {});
                                      Navigator.maybePop(context);
                                    });
                                  },
                                  onPressedDisableMedicine: () {
                                    setState(() {
                                      // print(alramId);
                                      medicine.disable =
                                          !(medicine.disable ?? false);
                                      medicine.save(); // 특정 필드만 변경할때에는 save해줘야함
                                      for (var alarm in medicineAlramTime) {
                                        alarm.disable =
                                            !(alarm.disable ?? false);
                                        alarm.save();
                                      }
                                      toggleNotificationsDisableState(medicine);
                                      // notification.deleteAllAlarm();
                                      // alarmTimeRepository.deleteAllAlramTime();
                                    });
                                    Navigator.pop(context);
                                  },
                                  onPressedDeleteOnlyMedicine: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            title: const Text(
                                              "약 정보를 삭제하시겠습니까?",
                                              style: TextStyle(fontSize: 15),
                                            ),
                                            content: const Text(
                                              "복약 기록은 삭제되지 않습니다.",
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12),
                                            ),
                                            actions: [
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                    deleteOnlyMedicine(
                                                        context,
                                                        alramId,
                                                        medicineAlramTime,
                                                        medicine);
                                                  },
                                                  child: const Text(
                                                    "확인",
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  )),
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text("취소")),
                                            ],
                                          );
                                        });
                                  },
                                ));
                      },
                    ),
                  ],
                ),
                children: List.generate(medicineAlramTime.length, (index) {
                  final alram = medicineAlramTime[index]; // 특정 약의 하나의 알람
                  return ListTile(
                    title: Row(
                      children: [
                        const SizedBox(width: 15),
                        Text(
                          checkAlarmTime(alram.alarmTIme),
                          style: TextStyle(color: disabledStateTextColor),
                        ),
                        const Spacer(),
                        Checkbox(
                            side: BorderSide(color: disabledStateTextColor),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(4) // 둥근 모서리의 정도 조절
                                ),
                            fillColor: MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                              return Colors.transparent; // 기본 색상
                            }),
                            activeColor: Colors.transparent,
                            checkColor: Colors.black54,
                            value: alram.checked,
                            onChanged: (medicine.disable == true ||
                                    (medicine.weekdays.isNotEmpty &&
                                        !medicine.weekdays
                                            .contains(DateTime.now().weekday)))
                                ? null
                                : (check) {
                                    setState(() {
                                      alram.checked = check ?? false;
                                      alram.checkedDate =
                                          DateFormat('yyyy-MM-dd')
                                              .format(DateTime.now());
                                      alram.save();

                                      if (alram.checked) {
                                        alram.calendarCheckDate.add(
                                            DateFormat('yyyy-MM-dd')
                                                .format(DateTime.now()));

                                        historyRepository.addHistory(
                                            MedicineHistory(
                                                medicineId: medicine.id,
                                                alarmTime: alram.alarmTIme,
                                                takeTime: DateTime.now(),
                                                medicineKey: alram.medicineKey,
                                                name: alram.name,
                                                imagePath: medicine.imagePath));
                                      } else {
                                        alram.calendarCheckDate.remove(
                                            DateFormat('yyyy-MM-dd')
                                                .format(DateTime.now()));
                                        final histories = historyRepository
                                            .historyBox.values
                                            .where((history) =>
                                                history.medicineKey ==
                                                    alram.medicineKey &&
                                                history.alarmTime ==
                                                    alram.alarmTIme &&
                                                DateFormat('yyyy-MM-dd').format(
                                                        history.takeTime) ==
                                                    DateFormat('yyyy-MM-dd')
                                                        .format(DateTime.now()))
                                            .toList();
                                        if (histories.isNotEmpty) {
                                          historyRepository.deleteHistory(
                                              histories.first.key);
                                        }
                                      }
                                    });
                                  })
                      ],
                    ),
                  );
                }),
              ),
            ),
          );
        });
  }
}

// medicine.weekdays 리스트를 요일 이름으로 변환
String weekdaysToString(Medicine medicine) {
  final Map<int, String> weekdayNames = {
    1: '월',
    2: '화',
    3: '수',
    4: '목',
    5: '금',
    6: '토',
    7: '일',
  };

  // List.from - 리스트 복사
  List<int> sortedWeekdays = List.from(medicine.weekdays)..sort();

  String weekdayToString;

  if (medicine.alarms.isEmpty) {
    weekdayToString = '';
  } else if (medicine.weekdays.isEmpty) {
    weekdayToString = "매일";
  } else {
    // 리스트 내 각 숫자를 요일 이름으로 변환하고, 결과를 콤마로 연결
    weekdayToString =
        sortedWeekdays.map((day) => weekdayNames[day] ?? '').join(', ');
  }

  // // 리스트 내 각 숫자를 요일 이름으로 변환하고, 결과를 콤마로 연결
  // return medicine.weekdays.isEmpty
  //     ? '매일'
  //     : sortedWeekdays.map((day) => weekdayNames[day] ?? '').join(', ');
  return weekdayToString;
}

Iterable<int> historyKeys(MedicineAlarmTime alram, Medicine medicine) {
  final Iterable<MedicineHistory> histories =
      historyRepository.historyBox.values.where((history) =>
          history.alarmTime == alram.alarmTIme &&
          history.medicineKey == medicine.key);

  final List<int> keys =
      histories.map((history) => history.key as int).toList();

  return keys;
}

bool isToday(DateTime source, DateTime destination) {
  return source.year == destination.year &&
      source.month == destination.month &&
      source.day == destination.day;
}

String checkAlarmTime(String alarmTimeStr) {
  List<String> time = alarmTimeStr.split(':');
  int hour = int.parse(time[0]);
  String min = time[1];
  return "${hour < 12 ? "오전" : "오후"} ${hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour)}:$min";
}

void toggleNotificationsDisableState(Medicine medicine) {
  if (medicine.disable!) {
    for (var alarm in medicine.alarms) {
      if (medicine.weekdays.isEmpty) {
        notification.deleteAlarm(notification.alarmId(medicine.id, alarm));
      } else {
        for (var day in medicine.weekdays) {
          notification
              .deleteAlarm(notification.alarmIdWeek(medicine.id, alarm, day));
        }
      }
    }
  } else {
    for (var alarm in medicine.alarms) {
      notification.addNotification(
          medicineId: medicine.id,
          alarmTimeStr: alarm,
          title: '$alarm 약 먹을 시간이에요!',
          body: '${medicine.name} 복약했다고 알려주세요!',
          notificationDays: medicine.weekdays);
    }
  }
}

void deleteAllMedicine(BuildContext context) {
  var now =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  var alramTimeLIst = alarmTimeRepository.alarmTimeBox.values.toList();

  for (var alarm in alramTimeLIst) {
    if (alarm.checked != true) {
      alarm.deleteDate = now;
      alarm.save();
      alarmTimeRepository.deleteAlarmTime(alarm.key);
    } else {
      alarm.deleteDate = now.add(const Duration(days: 1));
      alarm.save();
    }
  }

  notification.deleteAllAlarm();
  medicineRepository.deleteAllMedicine();

  Navigator.pop(context);
}

void deleteOnlyMedicine(BuildContext context, List<String> alarmId,
    List<MedicineAlarmTime> medicineAlramTime, Medicine medicine) {
  // 알람삭제 (id값을 알기위해)
  // print(alarmIds);

  var now =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  notification.deleteMultipleAlarm(alarmId);
  for (var alarm in medicineAlramTime) {
    // if (alarm.addDate == now && alarm.checked != true) {
    //   alarmTimeRepository.deleteAlarmTime(alarm.key);
    // } else {
    //   alarm.deleteDate = now.add(const Duration(days: 1));
    // }
    if (alarm.checked != true) {
      alarm.deleteDate = now;
      alarm.save();
      alarmTimeRepository.deleteAlarmTime(alarm.key);
    } else {
      alarm.deleteDate = now.add(const Duration(days: 1));
      alarm.save();
    }
  }
  // hive 데이터 삭제
  medicineRepository.deleteMedicine(medicine.key);

  // pop
  Navigator.pop(context);
}
