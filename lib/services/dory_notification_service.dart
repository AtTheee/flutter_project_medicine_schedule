import 'dart:developer';
import 'dart:io';
// import 'dart:js_util';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:flutter_native_timezone_updated_gradle/flutter_native_timezone.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final notification = FlutterLocalNotificationsPlugin();

class DoryNotificationService {
  Future<void> initializeTimeZone() async {
    tz.initializeTimeZones(); // 시간대 설정 초기화
    final timeZoneName =
        await FlutterNativeTimezone.getLocalTimezone(); // 디바이스 로컬 시간 가져옴
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  Future<void> initializeNotification() async {
    // PermissionStatus status = await Permission.camera.request();

    const initializationSettingsAndroid = AndroidInitializationSettings(
        '@mipmap/notification_launcher'); // 알림 기본 아이콘

// 알림 권한을 처음에 물어봄
    const initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await notification.initialize(
      initializationSettings,
    );
  }

  String alarmId(int medicineId, String alarmTIme, [int? day]) {
    return day == null
        ? medicineId.toString() + alarmTIme.replaceAll(':', '')
        : medicineId.toString() +
            alarmTIme.replaceAll(':', '') +
            day.toString();
  }

  String alarmIdWeek(int medicineId, String alarmTIme, int day) {
    return medicineId.toString() +
        alarmTIme.replaceAll(':', '') +
        day.toString();
  }

  Future<bool> addNotification({
    required int medicineId,
    required String alarmTimeStr,
    required String title, // HH:mm 약 먹을 시간이예요!
    required String body, // {약이름} 복약했다고 알려주세요!
    List<int>? notificationDays,
  }) async {
    if (!await permissionNotification) {
      // show native setting page // 권한이 없을 경우
      return false;
    }

    /// exception
    final now = tz.TZDateTime.now(tz.local);
    final alarmTime = DateFormat('HH:mm').parse(alarmTimeStr);
    final day = (alarmTime.hour < now.hour ||
            alarmTime.hour == now.hour && alarmTime.minute <= now.minute)
        ? now.day + 1
        : now.day; // 설정한 시간이 현재보다 작으면 하루 추가

    // id 알람 시간이 중복이 안되니 :를 뺀 숫자는 유니크하다(는 하나의 약에서만)
    // 내가 가진 앱에서 유니크 해야함
    String alarmTimeId = alarmId(medicineId, alarmTimeStr);

    // /// add schedule notification
    // final details = _notificationDetails(
    //   alarmTimeId, // unique
    //   title: title,
    //   body: body,
    // );

    if (notificationDays != null && notificationDays.isNotEmpty) {
      for (var dayOfWeek in notificationDays) {
        var scheduledDay =
            _nextWeekday(now, dayOfWeek, alarmTime); // 다음 지정 요일 계산

        await notification.zonedSchedule(
          int.parse(
              "$alarmTimeId${scheduledDay.weekday}"), // 유니크한 ID를 위해 요일을 추가
          title,
          body,
          scheduledDay,
          _notificationDetails(
            "$alarmTimeId${scheduledDay.weekday}", // unique
            title: title,
            body: body,
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents:
              DateTimeComponents.dayOfWeekAndTime, // 주간 반복 설정
          payload: alarmTimeId,
        );
      }
    } else {
      await notification.zonedSchedule(
        int.parse(alarmTimeId), // unique
        title,
        body,
        tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          day,
          alarmTime.hour,
          alarmTime.minute,
        ),
        _notificationDetails(
          alarmTimeId, // unique
          title: title,
          body: body,
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: alarmTimeId,
      );
    }
    log('[notification list] ${await pedingNotificationIds}');

    return true;
  }

  // 다음 지정된 요일에 해당하는 DateTime을 계산하는 함수
  tz.TZDateTime _nextWeekday(
      tz.TZDateTime now, int dayOfWeek, DateTime alarmTime) {
    var daysToAdd = (dayOfWeek - now.weekday) % 7;
    daysToAdd = daysToAdd <= 0
        ? daysToAdd + 7
        : daysToAdd; // 현재 요일이 지정 요일 이후인 경우 다음 주로 설정
    return tz.TZDateTime(tz.local, now.year, now.month, now.day + daysToAdd,
        alarmTime.hour, alarmTime.minute);
  }

  // _showNotification(
  //     String alarmTimeId,
  //     String title,
  //     String body,
  //     tz.TZDateTime _scheduledWeek(List<int> days),
  //     List<int>? selectedWeeks,
  //     NotificationDetails details) async {
  //   await notification.zonedSchedule(
  //     int.parse(alarmTimeId), // unique
  //     title,
  //     body,
  //     _scheduledWeek(selectedWeeks!),
  //     details,
  //     androidAllowWhileIdle: true,
  //     uiLocalNotificationDateInterpretation:
  //         UILocalNotificationDateInterpretation.absoluteTime,
  //     matchDateTimeComponents: DateTimeComponents.time,
  //     payload: alarmTimeId,
  //   );
  // }

  NotificationDetails _notificationDetails(
    String id, {
    required String title,
    required String body,
  }) {
    final android = AndroidNotificationDetails(
      id,
      title,
      channelDescription: body,
      importance: Importance.max,
      priority: Priority.max,
    );
    const ios = DarwinNotificationDetails();

    return NotificationDetails(
      android: android,
      iOS: ios,
    );
  }

  Future<bool> get permissionNotification async {
    final PermissionStatus status = await Permission.notification.request();
    if (Platform.isAndroid) {
      if (status.isPermanentlyDenied || status.isDenied) {
        return false;
      }
      return true;
    } else if (Platform.isIOS) {
      return await notification
              .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    } else {
      return false;
    }
  }

  Future<void> deleteMultipleAlarm(Iterable<String> alarmIds) async {
    log('[before delete norification list] ${await pedingNotificationIds}');

    for (final alarmId in alarmIds) {
      final id = int.parse(alarmId);

      await notification.cancel(id);
    }
    log('[after delete norification list] ${await pedingNotificationIds}');
  }

  Future<void> deleteAlarm(String alarmId) async {
    log('[before delete norification list] ${await pedingNotificationIds}');
    final id = int.parse(alarmId);
    await notification.cancel(id);

    log('[after delete norification list] ${await pedingNotificationIds}');
  }

  Future<void> deleteAllAlarm() async {
    log('[before delete norification list] ${await pedingNotificationIds}');
    await notification.cancelAll();
    log('[after delete norification list] ${await pedingNotificationIds}');
  }

  Future<List<int>> get pedingNotificationIds {
    final list = notification
        .pendingNotificationRequests()
        .then((value) => value.map((e) => e.id).toList());
    return list;
  }
}
