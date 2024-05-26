import 'package:dory/components/dory_colors.dart';
import 'package:dory/components/dory_constants.dart';
import 'package:dory/pages/history/history_calendar.dart';
import 'package:dory/pages/history/history_page.dart';
import 'package:dory/pages/today/today_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final _pages = [
    const TodayPage(),
    const HistoryCalendar(),
    const HistoryPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: pagePadding,
        child: SafeArea(child: _pages[_currentIndex]),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _onAddMedicine,
      //   child: const Icon(Icons.add),
      // ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomAppBar(),
    );
  }

  // 하단바
  BottomAppBar _buildBottomAppBar() {
    return BottomAppBar(
      // elevation: 0, // 그림자
      child: Container(
        height: kBottomNavigationBarHeight, // 기본적으로 하단바 높이 지정해놓음
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () => _onCurrentPage(0), // 한줄밖에 없으니 화살표 함수로 가능
              icon: const Icon(Icons.timer_outlined),
              color: _currentIndex == 0
                  ? DoryColors.primaryColor
                  : Colors.grey[350],
              tooltip: "알림",
            ),
            IconButton(
              onPressed: () => _onCurrentPage(1),
              icon: const Icon(Icons.calendar_month_outlined),
              color: _currentIndex == 1
                  ? DoryColors.primaryColor
                  : Colors.grey[350],
              tooltip: "달력",
            ),
            IconButton(
              onPressed: () => _onCurrentPage(2),
              icon: const Icon(CupertinoIcons.text_badge_checkmark),
              color: _currentIndex == 2
                  ? DoryColors.primaryColor
                  : Colors.grey[350],
              tooltip: "기록",
            ),
          ],
        ),
      ),
    );
  }

  void _onCurrentPage(int pageIndex) {
    setState(() {
      // 변경됨을 알림 setstate = build 재호출
      _currentIndex = pageIndex;
    });
  }

  // void _onAddMedicine() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => const AddPage(),
  //     ),
  //   );
  // }
}
