# Savvy Scope

![iphone 6 5](https://github.com/CHOIJUNHYUK01/Savvy-Scope/assets/114978803/55c0420a-582c-4525-8dac-cd240c14aa20)

v0.1.0 : 최근 30일 NASDAQ 등락율, 시가 총액 TOP 3 기업 데이터 보여주기 (2024.04.20)

<br /><br />

## 개발 배경
주식에 관한 공부를 위해 "부의 체인저"라는 책을 사서 읽었다. 이 책에는 특별하게 매뉴얼도 적혀있었다. 매우 상세했다.
1. 매일 NASDAQ 등락율을 본다. (-3% 확인)
2. 이를 기준으로 주식을 더 매수할지 아니면 매도할지 정한다.
3. 시가 총액이 바뀌는 시기기에 이도 신경써서 지켜봐야 한다.
4. 이를 기준으로 사야하는 기업이 바뀌기 때문이다.

위에서 나온 기준을 매일 봐야 좋기때문에, 이 앱의 초기 버전에 저 정보를 최대한 담았다.
추후에 더 자세한 매뉴얼을 따라가며 기능을 추가할 예정이다.

<br /><br />

## 프로젝트 기간
2024.04.05 ~ 2024.04.20 (15일) - v0.1.0

<br /><br />

## 개발 환경

### UI
- Code Base UI (UIKit)

### 디자인 패턴
- MVC 패턴

### 사용 기술 및 오픈소스 라이브러리
- Firebase Functions, Firebase Realtime Database, Google Cloud Functions Scheduler
- NodeJS, puppeteer
- [한국투자증권API](https://apiportal.koreainvestment.com/intro)

<br /><br />

## 문제 및 해결 과정

### 1. 너무 비싸고, 하루 제한이 빡빡한 주식 API

### 문제 상황

매일 시가 총액 기업 데이터와 NASDAQ 데이터를 불러와야 한다.
시가 총액 순위별로 내가 원하는, 전일 종가와 전일 대비 등락율, 시가 총액을 제공하는 API가 없었다.
한국투자증권API는 내가 얼마를 호출하든 무료다. 하지만, 시가 총액을 제공하진 않았다.
NASDAQ 같은 주식 관련 정보를 불러오는 API는 하루 제한이 빡빡하게 있고, 과금을 통해 더 부를 수 있는 시스템이다.

### 해결

나만의 DB와 서버를 만들기로 했다.
Firebase Functions와 Firebase Realtime Database를 이용해 매일 아침 6시 30분에 해당 정보를 정리해주는 사이트인 Investing.com 정보를 스크래핑하여 저장해 불러온다.

---

### 2. 앱을 켤때마다 너무 많이 부르는 데이터, 과금되지 않을까?

### 문제 상황

Firebase가 아무리 무료로도 사이드 프로젝트 정도는 돌릴 수 있는 용량을 제공해준다고 하더라도, 한 명의 악용하는 유저가 있다면 과금이 심해진다.
이를 방지하기 위한 방법이 필요했다.

### 해결

Core Data를 이용하기로 했다. 다만, 저장할 때 날짜를 기록하면서 해결했다.
시가 총액 데이터는 매일 6시 반을 기준으로 업데이트하도록 조건을 확인하고, 업데이트했다.
매일 업데이트를 해야하는 한국투자증권 API의 Access 토큰은 매일 밤 12시에 업데이트해 사용한다.
