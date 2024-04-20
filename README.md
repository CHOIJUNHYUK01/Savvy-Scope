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

**iOS**
- FSCalendar, Core Data

**서버 및 데이터베이스, API**
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

<br /><br />

### 2. 앱을 켤때마다 너무 많이 부르는 데이터, 과금되지 않을까?

### 문제 상황

Firebase가 아무리 무료로도 사이드 프로젝트 정도는 돌릴 수 있는 용량을 제공해준다고 하더라도, 한 명의 악용하는 유저가 있다면 과금이 심해진다.

이를 방지하기 위한 방법이 필요했다.

### 해결

Core Data를 이용하기로 했다. 다만, 저장할 때 날짜를 기록하면서 해결했다.

시가 총액 데이터는 매일 6시 반을 기준으로 업데이트하도록 조건을 확인하고, 업데이트했다.

매일 업데이트를 해야하는 한국투자증권 API의 Access 토큰은 매일 밤 12시에 업데이트해 사용한다.

<br /><br />

### 3. 데이터가 안 들어와요

### 문제 상황

Firebase에서 데이터를 불러와서 화면에 동기화를 시켜줘야 해서 GCD를 직렬큐로 만들어 데이터를 받아오면 컨트롤러한테 넘겨주게 했다.

하지만, GCD 큐 안에 있는 Firebase 데이터를 불러오는 함수가 비동기이기 때문에 이를 기다리지 않고, 빈 데이터 배열을 컨트롤러한테 넘기는 문제가 생겼다.

### 해결

DispatchGroup을 사용해 해결했다.

여러 스레드로 구성된 작업들을 끝나는 시점을 하나의 그룹으로 만들어 한 번에 파악하고, 다음 일을 지정할 수 있게 해줬다.

아래 코드와 같이 직렬큐에 미리 들어간 일들이 끝나는 시점을 각각 enter(), wait(), leave()를 통해서 언제 시작됐는지, 끝나는지, 언제까지 기다리는지를 알게 해준다.

```swift
 let queue = DispatchQueue(label: "FetchCorp")
 var newCorp: MarketcapCorp?
            
for i in 1...3 {
    let dispatchGroup = DispatchGroup()
    queue.async {
         newCorp = MarketcapCorp(title: "", symbol: "", marketcap: "", currentPrice: "", arise: false, rank: 0, date: Date())
         for data in ["arise", "capital", "name", "price", "symbol"] {
             dispatchGroup.enter() // 이제 시작
             self.ref.child("marketCap/\(i)/\(data)").getData { error, snapshot in
                  defer { dispatchGroup.leave() }
                          // Something in here
                    }
          }
    }
                
     queue.async {
          dispatchGroup.wait() // enter()된 시점부터, leave()할 때까지 대기
          // Something in here
      }
```
하면서 DB 구조를 다시 짜는 방법이 가장 편리하겠지만, 그 구조를 다시 짜기 위해 고쳐야할 것도 많고, 어떻게 짤 수 있는지 리서치하는 시간이 더 걸릴것이라고 판단했다.

그리고 데이터를 동기화하는데 불가능한 방법이 아니라고 판단했다.

이참에 GCD를 더 알게 된 시간이 되어 더 좋았다.
