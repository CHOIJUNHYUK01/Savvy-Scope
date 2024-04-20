//
//  NetworkManager.swift
//  StockSavvy
//
//  Created by CHOIJUNHYUK on 4/14/24.
//

import Foundation
import FirebaseDatabaseInternal

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    let coreDataManager = CoreDataManager.shared
    var ref: DatabaseReference! = Database.database().reference()
    let nasdaqDispatchGroup = DispatchGroup()
    
    func getAccessToken(completion: @escaping (String) -> Void) {
        let accessible = coreDataManager.getTokenIsAccessible()
        let tokenData = coreDataManager.getTokenFromCoreData()
        
        if !accessible {
            nasdaqDispatchGroup.enter()
            ref.child("accessToken/data").getData { error, snapshot in
                defer { self.nasdaqDispatchGroup.leave() }
                
                guard error == nil else {
                    print("ACCESS TOKEN ERROR : ",error!.localizedDescription)
                    return;
                }
                let token = snapshot?.value as? String ?? "Unknown";
                
                if tokenData == "Unknown" {
                    completion(token)
                    self.coreDataManager.saveTokenData(token: token)
                } else {
                    completion(token)
                    self.coreDataManager.updateTokenData(newToken: token)
                }
            }
        } else {
            completion(tokenData)
        }
    }
    
    func getMarketcapData(completion: @escaping (MarketcapCorp) -> Void) {
        let accessible = coreDataManager.getCorpIsAccessible()
        let corpDataList = coreDataManager.getCorpListFromCoreData()
        
        if !accessible {
            let queue = DispatchQueue(label: "FetchCorp")
            var newCorp: MarketcapCorp?
            
            for i in 1...3 {
                let dispatchGroup = DispatchGroup()
                queue.async {
                    newCorp = MarketcapCorp(title: "", symbol: "", marketcap: "", currentPrice: "", arise: false, rank: 0, date: Date())
                    for data in ["arise", "capital", "name", "price", "symbol"] {
                        dispatchGroup.enter()
                        self.ref.child("marketCap/\(i)/\(data)").getData { error, snapshot in
                            defer { dispatchGroup.leave() }
                            
                            guard error == nil else {
                                print(error!.localizedDescription)
                                return
                            }
                            newCorp?.rank = Int32(i)
                            if data == "arise" {
                                let ariseValue = snapshot?.value as? Int ?? 0;
                                newCorp?.arise = ariseValue == 1
                                return
                            }
                            
                            let eachData = snapshot?.value as? String ?? "Unknown";
                            switch data {
                            case "capital":
                                newCorp?.marketcap = eachData
                            case "name":
                                newCorp?.title = eachData
                            case "price":
                                newCorp?.currentPrice = eachData
                            case "symbol":
                                newCorp?.symbol = eachData
                            default:
                                break
                            }
                        }
                    }
                }
                
                queue.async {
                    dispatchGroup.wait()
                    guard let corpData = newCorp else {return}
                    completion(corpData)
                    if corpDataList.isEmpty {
                        self.coreDataManager.saveCorpDataList(newCorpData: corpData)
                    } else {
                        self.coreDataManager.updateCorpData(newCorpData: corpData)
                    }
                }
            }
        } else {
            coreDataManager.getCorpListFromCoreData().forEach { data in
                guard let title = data.title, let symbol = data.symbol, let marketcap = data.marketcap, let price = data.currentPrice, let date = data.date else {return}
                let tempData = MarketcapCorp(title: title, symbol: symbol, marketcap: marketcap, currentPrice: price, arise: data.arise, rank: data.rank, date: date)
                
                completion(tempData)
            }
        }
    }
    
    func getDataFromKIS(completion: @escaping (String) -> Void, calendarCompletion: @escaping ([(String, String)]) -> Void) {
        let APP_KEY = Bundle.main.object(forInfoDictionaryKey: "APP_KEY")!
        let APP_SECRET_FRONT = Bundle.main.object(forInfoDictionaryKey: "APP_SECRET") as! String
        let APP_SECRET_BACK = Bundle.main.object(forInfoDictionaryKey: "APP_SECRET_BACK") as! String
        let APP_SECRET = APP_SECRET_FRONT + "//" + APP_SECRET_BACK
        
        let queue = DispatchQueue(label: "FetchNasdaq")
        
        var token: String = ""
        
        queue.async {
            self.getAccessToken { tokenData in
                token = tokenData
            }
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        
        let today = Date()
        guard let minDate = Calendar.current.date(byAdding: .day, value: -33, to: today) else { return }
        
        let startDate = dateFormatter.string(from: minDate)
        let endDate = dateFormatter.string(from: today)
        
        let urlString = "https://openapi.koreainvestment.com:9443/uapi/overseas-price/v1/quotations/inquire-daily-chartprice?FID_COND_MRKT_DIV_CODE=N&FID_INPUT_ISCD=COMP&FID_INPUT_DATE_1=\(startDate)&FID_INPUT_DATE_2=\(endDate)&FID_PERIOD_DIV_CODE=D"
        
        queue.async {
            self.nasdaqDispatchGroup.wait()
            // Create the URL
            if let url = URL(string: urlString) {
                // Create the URLRequest object
                var request = URLRequest(url: url)

                // Set the HTTP method, e.g., GET, POST, etc.
                request.httpMethod = "GET"

                // Add HTTP headers
                request.setValue("application/json", forHTTPHeaderField: "content-type")
                request.setValue("Bearer \(token)", forHTTPHeaderField: "authorization")
                request.setValue("\(APP_KEY)", forHTTPHeaderField: "appkey")
                request.setValue("\(APP_SECRET)", forHTTPHeaderField: "appsecret")
                request.setValue("FHKST03030100", forHTTPHeaderField: "tr_id")

                // Create a URLSession data task
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                        return
                    }
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        print("HTTP Status Code: \(httpResponse.statusCode)")
                    }

                    if let data = data {
                        if let dataList = self.parseJSON(data) {
                            completion(dataList.todayData.todayRate)
                            
                            let calculatedDataList = dataList.prevDataList
                            let dataLength = calculatedDataList.count - 2
                            var calendarDataList: [(String, String)] = []
                            
                            for i in 0...dataLength {
                                let currentValue = Double(calculatedDataList[i].stockValue)
                                let prevValue = Double(calculatedDataList[i+1].stockValue)
                                
                                guard let cv = currentValue, let pv = prevValue else {return}
                                let rate = cv / pv * 100 - 100
                                let rateFormatter = NumberFormatter()
                                rateFormatter.minimumFractionDigits = 2 // 최소 소수점 자릿수
                                guard let formattedRate = rateFormatter.string(from: NSNumber(value: rate)) else {return}
                                
                                let dateString = calculatedDataList[i].stockDate
                                let year = String(dateString.prefix(4))
                                let month = String(dateString[dateString.index(dateString.startIndex, offsetBy: 4)..<dateString.index(dateString.startIndex, offsetBy: 6)])
                                let day = String(dateString.suffix(2))
                                
                                let formattedDateString = "\(year)-\(month)-\(day)"
                                calendarDataList.append((formattedDateString, formattedRate))
                            }
                            
                            calendarCompletion(calendarDataList)
                        } else {
                            print("Parse 실패")
                        }
                    }
                }

                // Start the task
                task.resume()
            }
        }
    }
    
    func parseJSON(_ nasdaqData: Data) -> NasdaqData? {
        do {
            let nasdaqData = try JSONDecoder().decode(NasdaqData.self, from: nasdaqData)
            return nasdaqData
        } catch {
            print("Parse JSON ERROR : ",error.localizedDescription)
            return nil
        }
    }
}
