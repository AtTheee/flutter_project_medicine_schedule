import 'package:dory/components/dory_themes.dart';
import 'package:dory/pages/home_page.dart';
import 'package:dory/repositories/dory_hive.dart';
import 'package:dory/repositories/medicine_alarmtime_repository.dart';
import 'package:dory/repositories/medicine_repository.dart';
import 'package:dory/services/dory_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'repositories/medicine_history_repository.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final notification = DoryNotificationService();
final hive = DoryHive();
final medicineRepository = MedicineRepository();
final historyRepository = MedicineHistoryRepository();
final alarmTimeRepository = MedicineAlarmTimeRepository();

Future<void> main() async {
  // notification 초기화
  WidgetsFlutterBinding.ensureInitialized();
  await notification.initializeTimeZone();
  await notification.initializeNotification();

  await hive.initializeHive(); // openbox? 가 되지 않고 접근하면 에러라 비동기로 해줌s

  await initializeDateFormatting(); // ko_KR을 위한 초기화

  Map<Permission, PermissionStatus> status = await [
    Permission.notification,
    Permission.storage,
    Permission.camera,
  ].request();

  if ((status[Permission.notification]!.isGranted ||
          status[Permission.notification]!.isLimited) &&
      (status[Permission.storage]!.isGranted ||
          status[Permission.storage]!.isLimited) &&
      (status[Permission.camera]!.isGranted ||
          status[Permission.camera]!.isLimited)) {
    // print('성공 + ${status[Permission.storage]!.isGranted}');
    resetChecks();
    runApp(const MyApp());
  } else {
    // print(status[Permission.storage]!.isGranted);
    runApp(const MyApp());
  }
  // runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: DoryThemes.lightTheme,
      home: const HomePage(),
      localizationsDelegates: const <LocalizationsDelegate<Object>>[
        // ... app-specific localization delegate(s) here
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
      ],
      // 폰트 사이즈에 의존 x = 기기 크기마다 다르게 하기
      builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!),
    );
  }
}

void resetChecks() {
  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final alarms = alarmTimeRepository.alarmTimeBox.values;

  for (var alarm in alarms) {
    if (alarm.checkedDate != today) {
      alarm.checked = false;
      alarm.save();
    }
  }
}
