//
//  CoreDataManager.swift
//  StockSavvy
//
//  Created by CHOIJUNHYUK on 4/15/24.
//

import UIKit
import CoreData

final class CoreDataManager {
    
    static let shared = CoreDataManager()
    private init() {}
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    // 임시 저장소
    lazy var context = appDelegate?.persistentContainer.viewContext
    
    // 엔터티 이름 (코어데이터에 저장된 객체)
    let tokenEntity = "Token"
    let corpEntity = "TopCorp"
    
    // MARK: 코어데이터에 저장된 데이터 모두 읽어오기
    func getTokenFromCoreData() -> String {
        var tokenData = "Unknown"
        // 임시저장소가 있는지 확인
        if let context = context {
            // 요청서
            let request = NSFetchRequest<NSManagedObject>(entityName: self.tokenEntity)
            
            do {
                // 임시저장소에서 (요청서를 통해서) 데이터 가져오기 (fetch 메서드)
                if let fetchedToken = try context.fetch(request) as? [Token] {
                    if let existedToken = fetchedToken.first {
                        tokenData = existedToken.token ?? "Unknown"
                    }
                }
            } catch {
                print("토큰 가져오기 실패")
            }
        }
        
        return tokenData
    }
    
    func getTokenIsAccessible() -> Bool {
        var accessible: Bool = false
        // 임시저장소가 있는지 확인
        if let context = context {
            // 요청서
            let request = NSFetchRequest<NSManagedObject>(entityName: self.tokenEntity)
            
            do {
                // 임시저장소에서 (요청서를 통해서) 데이터 가져오기 (fetch 메서드)
                if let fetchedToken = try context.fetch(request) as? [Token] {
                    if let existedToken = fetchedToken.first {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        
                        accessible = existedToken.dateString == dateFormatter.string(from: Date())
                        
                    }
                }
            } catch {
                print("토큰 날짜 가져오기 실패")
            }
        }
        return accessible
    }
    
    func getCorpListFromCoreData() -> [TopCorp] {
        var corpDataList: [TopCorp] = []
        // 임시저장소가 있는지 확인
        if let context = context {
            // 요청서
            let request = NSFetchRequest<NSManagedObject>(entityName: self.corpEntity)
            // 정렬 순서를 정해서 요청서에 넘겨주기
            let rankOrder = NSSortDescriptor(key: "rank", ascending: true)
            request.sortDescriptors = [rankOrder]
            
            do {
                // 임시저장소에서 (요청서를 통해서) 데이터 가져오기 (fetch 메서드)
                if let fetchedCorpDataList = try context.fetch(request) as? [TopCorp] {
                    corpDataList = fetchedCorpDataList
                }
            } catch {
                print("기업 데이터 가져오기 실패")
            }
        }
        
        return corpDataList
    }
    
    func getCorpIsAccessible() -> Bool {
        var accessible: Bool = false
        // 임시저장소가 있는지 확인
        if let context = context {
            // 요청서
            let request = NSFetchRequest<NSManagedObject>(entityName: self.corpEntity)
            
            do {
                // 임시저장소에서 (요청서를 통해서) 데이터 가져오기 (fetch 메서드)
                if let fetchedCorpDataList = try context.fetch(request) as? [TopCorp] {
                    if let existedCorpData = fetchedCorpDataList.first {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        
                        if existedCorpData.dateString! == dateFormatter.string(from: Date()) {
                            if existedCorpData.timeString! > "06:35" {
                                accessible = true
                            }
                        }
                    }
                }
            } catch {
                print("토큰 날짜 가져오기 실패")
            }
        }
        return accessible
    }
    
    // MARK: 코어데이터에 데이터 생성하기
    func saveTokenData(token: String) {
        // 임시저장소 있는지 확인
        if let context = context {
            // 임시저장소에 있는 데이터를 그려줄 형태 파악하기
            if let entity = NSEntityDescription.entity(forEntityName: self.tokenEntity, in: context) {
                // 임시저장소에 올라가게 할 객체 만들기
                if let tokenData = NSManagedObject(entity: entity, insertInto: context) as? Token {
                    tokenData.date = Date()
                    tokenData.token = token
                    
                    if context.hasChanges {
                        do {
                            try context.save()
                        } catch {
                            print("토큰 저장 실패")
                        }
                    }
                }
            }
        }
    }
    
    func saveCorpDataList(newCorpData: MarketcapCorp) {
        // 임시저장소 있는지 확인
        if let context = context {
            // 임시저장소에 있는 데이터를 그려줄 형태 파악하기
            if let entity = NSEntityDescription.entity(forEntityName: self.corpEntity, in: context) {
                // 임시저장소에 올라가게 할 객체 만들기
                if let corpData = NSManagedObject(entity: entity, insertInto: context) as? TopCorp {
                    corpData.date = Date()
                    corpData.rank = newCorpData.rank
                    corpData.title = newCorpData.title
                    corpData.symbol = newCorpData.symbol
                    corpData.currentPrice = newCorpData.currentPrice
                    corpData.marketcap = newCorpData.marketcap
                    corpData.arise = newCorpData.arise
                    
                    if context.hasChanges {
                        do {
                            try context.save()
                        } catch {
                            print("기업 데이터 저장 실패", error.localizedDescription, newCorpData)
                        }
                    }
                }
                
            }
        }
    }
    
    // MARK: 코어데이터에서 데이터 수정하기 (일치하는 데이터 찾아서 수정)
    func updateTokenData(newToken: String) {
        if let context = context {
            let request = NSFetchRequest<NSManagedObject>(entityName: self.tokenEntity)
            
            do {
                if let fetchedToken = try context.fetch(request) as? [Token] {
                    if let tokenData = fetchedToken.first {
                        tokenData.date = Date()
                        tokenData.token = newToken
                        
                        if context.hasChanges {
                            do {
                                try context.save()
                            } catch {
                                print("토큰 업데이트 저장 실패")
                            }
                        }
                    }
                }
            } catch {
                print("토큰 업데이트 실패")
            }
        }
    }
    
    func updateCorpData(newCorpData: MarketcapCorp) {
        if let context = context {
            let request = NSFetchRequest<NSManagedObject>(entityName: self.corpEntity)
            // 단서, 찾기 위한 조건 설정
            request.predicate = NSPredicate(format: "rank == %d", newCorpData.rank)
            
            do {
                if let fetchedCorpData = try context.fetch(request) as? [TopCorp] {
                    if let corpData = fetchedCorpData.first {
                        corpData.date = Date()
                        corpData.title = newCorpData.title
                        corpData.symbol = newCorpData.symbol
                        corpData.currentPrice = newCorpData.currentPrice
                        corpData.marketcap = newCorpData.marketcap
                        corpData.arise = newCorpData.arise
                        
                        if context.hasChanges {
                            do {
                                try context.save()
                            } catch {
                                print("기업 업데이트 저장 실패")
                            }
                        }
                    }
                }
            } catch {
                print("기업 데이터 업데이트 실패")
            }
        }
    }
}
