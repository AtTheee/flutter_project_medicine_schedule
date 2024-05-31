# 프로젝트 소개

- 개인 프로젝트로 만들어 본 '약케줄' 모바일 앱 입니다.
- 복용해야 하는 약의 정보와 복용 알림 기능과 복약 기록에 대한 서비스를 제공합니다.

## 개발환경 및 사용기술
- IDE : Visual Studio Code
- Language : Dart
- Framework : Flutter 
- DB : Hive(NoSQL)
- Emulator : API 33(Android)

## 데이터베이스 구조
<table>
  <tr>
    <td>medicine</td>
    <td>약 정보 관리</td>
  </tr>
   <tr>
    <td>medicine_alarmtime</td>
    <td>약 알림시간 관리</td>
  </tr>
   <tr>
    <td>medicine_history</td>
    <td>복약 정보 관리</td>
  </tr>
</table>

## 주요 기능
- 약의 정보를 이미지와 함께 저장이 가능하다.
- 약을 복용해야 하는 시간에 알림을 설정할 수 있다.
- 알림 설정은 요일별로도 가능하다.
- 모든 약의 정보는 알림 시간과 같이 CRUD가 가능하다.
- 알림을 비활성화 할 수 있다.
- 약을 먹었는지 체크하는 기능이 있다.
- 달력에서 내가 뭘 복약했고, 무엇을 놓쳤는지 알 수 있다.
- 모든 복약 기록은 history 페이지에서 확인이 가능하다.
- history는 CRUD 가 가능하며 약의 이름으로 검색도 가능하다.

## 실제 서비스 화면

![medicine1](https://github.com/AtTheee/flutter_project_medicine_schedule/assets/139583539/9d7ff7a3-e73e-4b34-96fb-52df4376f56a)
![medicine2](https://github.com/AtTheee/flutter_project_medicine_schedule/assets/139583539/a4e99e96-97f5-4e49-875d-5afa37921042)
![medicine3](https://github.com/AtTheee/flutter_project_medicine_schedule/assets/139583539/3548df69-51fa-4299-a757-af55d355a3e9)
![medicine4](https://github.com/AtTheee/flutter_project_medicine_schedule/assets/139583539/58d760e2-1d70-4267-8b3e-5dc878bc5fdd)
