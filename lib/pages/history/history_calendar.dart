import 'package:dory/components/dory_constants.dart';
import 'package:dory/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../models/medicine_alarmtime.dart';
import '../../models/medicine_history.dart';

class HistoryCalendar extends StatefulWidget {
  const HistoryCalendar({super.key});

  @override
  State<HistoryCalendar> createState() => _HistoryCalendarState();
}

class _HistoryCalendarState extends State<HistoryCalendar> {
  DateTime now =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  DateTime? selectedDay;
  DateTime focusedDay =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  Map<DateTime, List<Event>> events = eventFromHistory();

  void updateEvents() {
    events = eventFromHistory(); // 이벤트 데이터를 새로 가져오는 함수를 다시 호출
  }

  List<Event> _getEventForDay(DateTime day) {
    return events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
              child:
                  Text('약케줄', style: Theme.of(context).textTheme.headlineSmall),
            ),
          ],
        ),
        const SizedBox(height: smallSpace),
        const Divider(height: 1, thickness: 1.0),
        TableCalendar(
          locale: 'ko_KR',
          firstDay: DateTime(1900),
          lastDay: DateTime(2100),
          focusedDay: focusedDay,
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
          onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
            setState(() {
              this.selectedDay = focusedDay;
              this.focusedDay = focusedDay;
              // print('focusedDay: ${focusedDay}');
              // print('now: ${now}');
              // print('Comparison result: ${focusedDay == now}');
            });
          },
          selectedDayPredicate: (DateTime day) {
            return selectedDay != null && day == selectedDay;
          },
          eventLoader: _getEventForDay,
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, day, events) {
              if (events.isNotEmpty) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.blueGrey,
                    shape: BoxShape.circle,
                  ),
                  width: 4,
                  height: 25,
                );
              }
              return null;
            },
            defaultBuilder: (context, day, focusedDay) {
              return DefaultBoxDecoration(day);
            },
            selectedBuilder: (context, day, focusDay) {
              // print(DateTime(DateTime.now().year, DateTime.now().month,
              //     DateTime.now().day));
              if (!isSameDay(selectedDay, now) || selectedDay != null) {
                return SelectedBoxEdcoration(day);
              } else {
                return DefaultBoxDecoration(day);
              }
            },
            todayBuilder: (context, day, focusedDay) {
              if (selectedDay == null) {
                return SelectedBoxEdcoration(day);
              } else {
                return DefaultBoxDecoration(day);
              }
            },
          ),
        ),
        const SizedBox(height: regularSpace),
        Text(DateFormat('yyyy.MM.dd', 'ko').format(focusedDay).toString()),
        const SizedBox(height: regularSpace),
        Expanded(
          child: calendarListView(),
        ),
      ],
    );
  }

  ListView calendarListView() {
    bool isListViewDisplay(MedicineAlarmTime alarmTime, DateTime focusedDate) {
      final addDateOnly = DateTime(alarmTime.addDate.year,
          alarmTime.addDate.month, alarmTime.addDate.day);
      final focusedDateOnly =
          DateTime(focusedDate.year, focusedDate.month, focusedDate.day);

      bool isAddedBeforeFocusedDate = focusedDateOnly.isAfter(addDateOnly) ||
          focusedDateOnly.isAtSameMomentAs(
              addDateOnly); // 선택한 날짜가 추가한 알람과 같은 날이거나 이후면 true
      bool isNotDeletedDeletedAfter = alarmTime.deleteDate == null ||
          focusedDate.isBefore(
              alarmTime.deleteDate!); // 알람을 삭제하지 않았고, 삭제한 날짜 이전이면 true
      bool isNotDisabled = alarmTime.disable != true; // 활성화 돼있으면 true
      bool shouldDisplayToday =
          alarmTime.weekdays.contains(focusedDate.weekday) ||
              alarmTime.weekdays.isEmpty; // 선택한 날짜의 요일이 알람이 울리는 요일에 포함되면 true

      return isAddedBeforeFocusedDate &&
          isNotDeletedDeletedAfter &&
          isNotDisabled &&
          shouldDisplayToday;
    }

    List<MedicineAlarmTime> filteredAlarmTimes = alarmTimeRepository
        .alarmTimeBox.values
        .where((alarmTime) => isListViewDisplay(alarmTime, focusedDay))
        .toList();

    return ListView.builder(
      itemCount: filteredAlarmTimes.length,
      itemBuilder: (context, index) {
        filteredAlarmTimes.sort(((a, b) => a.alarmTIme.compareTo(b.alarmTIme)));

        final event = filteredAlarmTimes[index];
        Color disabledStateTextColor =
            DateTime(focusedDay.year, focusedDay.month, focusedDay.day) !=
                    DateTime(now.year, now.month, now.day)
                ? Colors.grey
                : Colors.black;

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: disabledStateTextColor, width: 1),
              ),
              child: Row(
                children: [
                  const SizedBox(width: smallSpace),
                  Expanded(
                    flex: 1,
                    child: Text(event.name, overflow: TextOverflow.ellipsis),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(checkAlarmTime(event.alarmTIme)),
                  ),
                  Checkbox(
                    side: BorderSide(color: disabledStateTextColor),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4) // 둥근 모서리의 정도 조절
                        ),
                    fillColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                      return Colors.transparent; // 기본 색상
                    }),
                    activeColor: Colors.white,
                    checkColor: Colors.black54,
                    value: event.checked &&
                            event.checkedDate ==
                                DateFormat('yyyy-MM-dd').format(focusedDay) ||
                        event.calendarCheckDate.contains(
                            DateFormat('yyyy-MM-dd').format(
                                focusedDay)), // 체크가 true이고, 체크한 날짜가 선택한 날짜이거나, 체크한 날짜 리스트에 선택한 날짜가 포함되면 체크 상태로 유지.
                    onChanged: DateTime(focusedDay.year, focusedDay.month,
                                focusedDay.day) !=
                            DateTime(now.year, now.month, now.day)
                        ? null
                        : (check) {
                            setState(() {
                              event.checked = check ?? false;
                              event.save();

                              if (event.checked) {
                                // 체크할 경우
                                event.calendarCheckDate.add(
                                    DateFormat('yyyy-MM-dd').format(
                                        now)); // 체크한 날짜 리스트에 현재 날짜를 추가한다.

                                historyRepository.addHistory(MedicineHistory(
                                    // 복용 기록 추가
                                    medicineId: event.medicineKey,
                                    alarmTime: event.alarmTIme,
                                    takeTime: DateTime.now(),
                                    medicineKey: event.medicineKey,
                                    name: event.name,
                                    imagePath: event.imagePath));
                              } else {
                                // 체크 해제할 경우
                                // 먹었다고 체크하고 약정보 삭제했는데 남아있는 달력 리스트에서 다시 체크해제하면 없어지게
                                if (!medicineRepository.medicineBox
                                    .containsKey(event.medicineKey)) {
                                  // 약 정보가 삭제됐으면 알람 정보 삭제
                                  alarmTimeRepository.alarmTimeBox
                                      .delete(event.key);
                                }
                                event.calendarCheckDate.remove(
                                    DateFormat('yyyy-MM-dd')
                                        .format(now)); // 체크한 날짜 리스트에서 오늘 날짜 삭제
                                final histories = historyRepository
                                    .historyBox.values
                                    .where((history) =>
                                        history.medicineKey ==
                                            event.medicineKey &&
                                        history.alarmTime == event.alarmTIme &&
                                        DateFormat('yyyy-MM-dd')
                                                .format(history.takeTime) ==
                                            DateFormat('yyyy-MM-dd')
                                                .format(DateTime.now()))
                                    .toList();
                                if (histories.isNotEmpty) {
                                  historyRepository.deleteHistory(
                                      histories.first.key); // 복용 기록을 찾아 삭제
                                }
                              }
                              updateEvents();
                            });
                          },
                  )
                ],
              ),
            ),
            const SizedBox(height: smallSpace),
          ],
        );
      },
    );
  }
}

Iterable<int> historyKeys(MedicineAlarmTime alram) {
  final Iterable<MedicineHistory> histories =
      historyRepository.historyBox.values.where((history) =>
          history.alarmTime == alram.alarmTIme &&
          history.medicineKey == alram.medicineKey);

  final List<int> keys =
      histories.map((history) => history.key as int).toList();

  return keys;
}

class Event {
  String medicineName;
  String alram;
  Event(this.medicineName, this.alram);
}

Map<DateTime, List<Event>> eventFromHistory() {
  Map<DateTime, List<Event>> events = {};
  var histories = historyRepository.historyBox.values.toList();
  for (var history in histories) {
    // medicineKey -2 는 복약 기록 추가로 직접 추가한 기록들인데 달력에는 마커 표시 안되게 해놨음 일단
    if (history.medicineKey != -2) {
      DateTime date = history.takeTime;
      DateTime dateKey = DateTime(date.year, date.month, date.day);

      Event event = Event(
          history.name, DateFormat('yyyy-MM-dd').format(history.takeTime));

      if (events.containsKey(dateKey)) {
        events[dateKey]!.add(event);
      } else {
        events[dateKey] = [event];
      }
    }
  }

  return events;
}

class DefaultBoxDecoration extends StatelessWidget {
  const DefaultBoxDecoration(
    this.day, {
    super.key,
  });

  final DateTime day;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        day.day.toString(),
        style: TextStyle(
            color: day.weekday == DateTime.sunday ? Colors.red : Colors.black),
      ),
    );
  }
}

class SelectedBoxEdcoration extends StatelessWidget {
  const SelectedBoxEdcoration(
    this.day, {
    super.key,
  });

  final DateTime day;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 1),
          borderRadius: BorderRadius.circular(10)),
      child: Center(
        child: Text(
          day.day.toString(),
          style: TextStyle(
              color: day.weekday == DateTime.sunday ? Colors.red : Colors.black,
              fontWeight: FontWeight.w400),
        ),
      ),
    );
  }
}

String checkAlarmTime(String alarmTimeStr) {
  List<String> time = alarmTimeStr.split(':');
  int hour = int.parse(time[0]);
  String min = time[1];
  return "${hour < 12 ? "오전" : "오후"} ${hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour)}:$min 알림";
}
