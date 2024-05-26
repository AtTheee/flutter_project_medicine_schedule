import 'dart:io';

import 'package:dory/components/dory_constants.dart';
import 'package:dory/components/dory_page_route.dart';
import 'package:dory/main.dart';
import 'package:dory/models/medicine.dart';
import 'package:dory/pages/history/add_history_page.dart';
import 'package:dory/pages/today/history_empty_widget.dart';
import 'package:dory/pages/today/image_detail_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/medicine_history.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final _controller = TextEditingController();
  List<MedicineHistory> histories =
      historyRepository.historyBox.values.toList().reversed.toList();
  List<MedicineHistory> filterHistories = [];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_filterHistories);
    filterHistories = histories;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _filterHistories() {
    if (_controller.text.isEmpty) {
      filterHistories = histories;
    } else {
      filterHistories = histories.where((history) {
        return history.name
            .toLowerCase()
            .contains(_controller.text.toLowerCase());
      }).toList();
    }

    setState(() {});
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
              padding: textFieldContentPadding,
              child: Text(
                '복약 기록',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(width: regularSpace),
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                    hintText: '약 이름을 검색해주세요.',
                    hintStyle:
                        const TextStyle(fontSize: 13, color: Colors.black38),
                    suffixIcon: const Icon(Icons.search),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Colors.black45))),
                onChanged: (_) {
                  _filterHistories();
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddHistoryPage()),
                );

                // AddHistoryPage에서 true가 반환되면 상태 업데이트
                if (result == true) {
                  setState(() {
                    // historyRepository에서 최신 history 데이터를 다시 로드합니다.
                    final updatedHistories = historyRepository.historyBox.values
                        .toList()
                        .reversed
                        .toList();

                    // histories 리스트를 업데이트합니다.
                    histories = updatedHistories;

                    // filterHistories도 업데이트하는데, 이때 _controller의 현재 텍스트 값을 기준으로 필터링을 다시 수행합니다.
                    if (_controller.text.isEmpty) {
                      filterHistories = updatedHistories;
                    } else {
                      filterHistories = updatedHistories.where((history) {
                        return history.name
                            .toLowerCase()
                            .contains(_controller.text.toLowerCase());
                      }).toList();
                    }
                  });
                }
              },
            ),
          ],
        ),
        const SizedBox(height: smallSpace),
        const Divider(height: 1, thickness: 1.0),
        const SizedBox(height: smallSpace),
        Expanded(
            child: // 변화감지해서 다시 그림
                _buildListView(context, filterHistories)),
      ],
    );
  }

  Widget _buildListView(context, List<MedicineHistory> histories) {
    // final histories = historyBox.values.toList().reversed.toList();
    // final histories = []; // 임시 더미(히스토리내역이 아무것도 없을 때)
    if (histories.isEmpty) {
      return const HistoryEmpty();
    }
    return ListView.builder(
      itemCount: histories.length,
      itemBuilder: (context, index) {
        final history = histories[index];
        return _TimeTile(
          history: history,
          onDelete: () {
            setState(() {
              histories.remove(history);
              historyRepository.deleteHistory(history.key);
            });
          },
        );
      },
    );
  }
}

class _TimeTile extends StatelessWidget {
  const _TimeTile({
    required this.history,
    required this.onDelete,
  });

  final MedicineHistory history;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black38),
            borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: smallSpace),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: Row(
                  children: [
                    Text(
                      DateFormat('yyyy년 MM월 dd일 E요일', 'ko_KR')
                          .format(history.takeTime),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        onDelete();
                      },
                      icon: const Icon(CupertinoIcons.trash),
                      iconSize: 18,
                      color: Colors.black38,
                      padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                    )
                  ],
                ),
              ),
              // const SizedBox(height: smallSpace),
              const Divider(height: 1, thickness: 1.0),
              Row(
                children: [
                  CupertinoButton(
                    onPressed: medicine.imagePath == null
                        ? null
                        : () {
                            Navigator.push(
                                context,
                                FadePageRoute(
                                    page: ImageDetailPage(
                                        imagePath: medicine.imagePath!)));
                          },
                    child: Container(
                      width: 60.0, // 너비 설정
                      height: 60.0, // 높이 설정
                      decoration: BoxDecoration(
                        color: Colors.white, // 배경 색상
                        image: medicine.imagePath != null
                            ? DecorationImage(
                                image: FileImage(File(medicine.imagePath!)),
                                fit: BoxFit.cover, // 이미지가 컨테이너를 꽉 채우도록
                              )
                            : null,
                        borderRadius:
                            BorderRadius.circular(10), // 모서리 둥글기 (0은 완전한 사각형)
                      ),
                      child: medicine.imagePath == null
                          ? const Center(
                              child: Text('💊',
                                  style: TextStyle(
                                      fontSize: 35))) // 이미지가 없을 때 텍스트 중앙에 표시
                          : null, // 이미지가 있을 때는 텍스트를 표시하지 않음
                    ),
                  ),
                  const SizedBox(width: regularSpace),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                          '${DateFormat('a hh:mm', 'ko_KR').format(history.takeTime)}\n\n${medicine.name}'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Medicine get medicine {
    return medicineRepository.medicineBox.values.singleWhere(
        (element) =>
            element.id == history.medicineId &&
            element.key == history.medicineKey,
        orElse: () => Medicine(
            // 해당하는게 없으면
            id: -1,
            name: history.name, //'삭제된 약입니다.',
            imagePath: history.imagePath,
            alarms: [],
            weekdays: []));
  }
}
