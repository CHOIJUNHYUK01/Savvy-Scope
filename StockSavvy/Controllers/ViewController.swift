//
//  ViewController.swift
//  StockSavvy
//
//  Created by CHOIJUNHYUK on 4/3/24.
//

import UIKit
import FSCalendar

final class ViewController: UIViewController {
    
    let networkManager = NetworkManager.shared
    let coreDataManager = CoreDataManager.shared
    
    let mainView = MainView()
    private lazy var nasdaqCalenderView = mainView.nasdaqCalendarView
    
    var corpDataList: [MarketcapCorp] = [] {
        didSet {
            if corpDataList.count == 3 {
                mainView.marketcapData = corpDataList
            }
        }
    }
    
    var calendarDataList: [(String, String)] = [] {
        didSet {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            for data in calendarDataList {
                if data.1.hasPrefix("-3") {nasdaqWarning.append(data.0)}
                
                let negative = data.1.hasPrefix("-")
                if let date = dateFormatter.date(from: data.0) {
                    calendarDateColoredMap[date] = negative ? .systemBlue : .systemRed
                    calendarDateSubtitleMap[date] = data.1
                }
            }
        }
    }
    
    var nasdaqWarning: [String] = [] {
        didSet {
            mainView.nasdaqWarningCount = nasdaqWarning.count
        }
    }
    
    var calendarDateColoredMap: [Date: UIColor] = [:]
    
    var calendarDateSubtitleMap: [Date: String] = [:] {
        didSet {
            mainView.nasdaqCalendarFetched = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view = mainView
        title = "Stock Savvy"
        
        networkManager.getMarketcapData { [weak self] corpData in
            self?.corpDataList.append(corpData)
        }
        
        setupCalendarView()
        
        networkManager.getDataFromKIS { [weak self] todayRate in
            self?.mainView.nasdaqTodayRate = todayRate
        } calendarCompletion: { [weak self] calendarDataList in
            self?.calendarDataList = calendarDataList
        }
    }
    
    func setupCalendarView() {
        nasdaqCalenderView.delegate = self
        nasdaqCalenderView.dataSource = self
    }
}

// MARK: NASDAQ Calendar
extension ViewController: FSCalendarDelegate, FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        return calendarDateColoredMap[date] ?? .darkGray
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        return false
    }
    
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
        return calendarDateSubtitleMap[date] ?? ""
    }
}
extension ViewController: FSCalendarDataSource {
    func minimumDate(for calendar: FSCalendar) -> Date {
        let today = Date()
        let minDate = Calendar.current.date(byAdding: .day, value: -30, to: today)
        return minDate ?? today
    }
    
    func maximumDate(for calendar: FSCalendar) -> Date {
        return Date()
    }
}
