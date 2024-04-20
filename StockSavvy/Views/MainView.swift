//
//  mainView.swift
//  StockSavvy
//
//  Created by CHOIJUNHYUK on 4/14/24.
//

import UIKit
import FSCalendar

final class MainView: UIView {
    
    var marketcapData: [MarketcapCorp] = [] {
        didSet {
            marketcapData.forEach { corp in
                DispatchQueue.main.async {
                    let corpView = MarketcapEachView()
                    corpView.corpTitle = corp.title
                    corpView.corpSymbol = corp.symbol
                    corpView.corpCurrentPrice = corp.currentPrice
                    corpView.corpMarketcap = corp.marketcap
                    corpView.arise = corp.arise
                    
                    self.marketcapCorpStackView.addArrangedSubview(corpView)
                }
            }
        }
    }
    
    var nasdaqTodayRate: String = "0.0%" {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let weakSelf = self else {return}
                weakSelf.nasdaqSubLabel.text = weakSelf.nasdaqTodayRate + "%"
                
                if weakSelf.nasdaqTodayRate.starts(with: "-") {
                    weakSelf.nasdaqSubLabel.backgroundColor = .systemBlue
                } else {
                    weakSelf.nasdaqSubLabel.backgroundColor = .systemRed
                }
            }
        }
    }
    
    var nasdaqCalendarFetched: Bool = false {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.nasdaqCalendarView.reloadData()
            }
        }
    }
    
    var nasdaqWarningCount: Int = 0 {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let weakSelf = self else {return}
                switch weakSelf.nasdaqWarningCount {
                case 1 :
                    weakSelf.postMinusLabel.text = "-3% once this month"
                case 2 :
                    weakSelf.postMinusLabel.text = "-3% twice this month"
                case 3 :
                    weakSelf.postMinusLabel.text = "-3% thrice this month"
                default:
                    weakSelf.postMinusLabel.text = "Beginning to feel panicky"
                }
                
                switch weakSelf.nasdaqWarningCount {
                case 1...3:
                    let fullText = "Recommended to Sell"
                    // 매수라는 단어에 색을 적용합니다.
                    let attributedString = NSMutableAttributedString(string: fullText)
                    let highlightColor = UIColor.systemBlue // 매수라는 단어에 적용할 색

                    // 매수라는 단어의 범위를 찾아 색을 적용합니다.
                    if let buyRange = attributedString.string.range(of: "Sell") {
                        let nsRange = NSRange(buyRange, in: attributedString.string)
                        attributedString.addAttribute(.foregroundColor, value: highlightColor, range: nsRange)
                    }

                    // UILabel에 적용된 텍스트를 설정합니다.
                    weakSelf.preferenceLabel.attributedText = attributedString
                default:
                    break
                }
            }
        }
    }
    
    private lazy var mainScrollView: UIScrollView = {
        let scv = UIScrollView()
        scv.backgroundColor = .black
        return scv
    }()
    
    // MARK: 메인 스택뷰
    private lazy var mainStackView: UIStackView = {
        let st = UIStackView(arrangedSubviews: [mainTopStackView, dividerView, marketcapStackView])
        st.axis = .vertical
        st.distribution = .fill
        st.spacing = 20
        return st
    }()
    
    // MARK: 메인 상단 스택뷰
    private lazy var mainTopStackView: UIStackView = {
        let st = UIStackView(arrangedSubviews: [nasdaqLabelStackView, nasdaqCalendarView, preferenceLabelStackView])
        st.axis = .vertical
        st.distribution = .fill
        st.spacing = 20
        return st
    }()
    
    // MARK: 나스닥 라벨
    private lazy var nasdaqLabelStackView: UIStackView = {
        let st = UIStackView(arrangedSubviews: [nasdaqLabel, nasdaqSubLabel])
        st.axis = .horizontal
        st.distribution = .fillProportionally
        return st
    }()
    
   private let nasdaqLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "NASDAQ"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        return label
    }()
    
    private var nasdaqSubLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 24, weight: .regular)
        label.textAlignment = .center
        label.clipsToBounds = true
        label.layer.cornerRadius = 8
        return label
    }()
    
    // MARK: 나스닥 달력
    lazy var nasdaqCalendarView: FSCalendar = {
        let calendar = FSCalendar()
        calendar.backgroundColor = .black
        calendar.scope = .month
        calendar.appearance.weekdayFont = UIFont.systemFont(ofSize: 12, weight: .bold)
        calendar.appearance.weekdayTextColor = .white
        calendar.appearance.titleWeekendColor = .lightGray
        calendar.appearance.titleDefaultColor = .white
        calendar.appearance.todayColor = .none
        calendar.appearance.todaySelectionColor = .none
        calendar.appearance.selectionColor = .none
        calendar.appearance.subtitleDefaultColor = .lightGray
        return calendar
    }()
    
    // MARK: 매수 및 매도 추천 문구
    private lazy var preferenceLabelStackView: UIStackView = {
       let st = UIStackView(arrangedSubviews: [postMinusLabel, preferenceLabel])
        st.axis = .vertical
        st.distribution = .fill
        st.spacing = 4
        return st
    }()
    
    private var postMinusLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "No -3% this month"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .center
        return label
    }()
    
    private var preferenceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        
        let fullText = "Recommended to Buy"
        // 매수라는 단어에 색을 적용합니다.
        let attributedString = NSMutableAttributedString(string: fullText)
        let highlightColor = UIColor.systemRed // 매수라는 단어에 적용할 색

        // 매수라는 단어의 범위를 찾아 색을 적용합니다.
        if let buyRange = attributedString.string.range(of: "Buy") {
            let nsRange = NSRange(buyRange, in: attributedString.string)
            attributedString.addAttribute(.foregroundColor, value: highlightColor, range: nsRange)
        }

        // UILabel에 적용된 텍스트를 설정합니다.
        label.attributedText = attributedString
        
        return label
    }()
    
    private let dividerView: UIView = {
        let divider = UIView()
        divider.backgroundColor = .gray
        return divider
    }()
    
    // MARK: 시가 총액 순위
    private lazy var marketcapStackView: UIStackView = {
       let st = UIStackView(arrangedSubviews: [marketcapLabelStackView, marketcapCorpStackView])
        st.axis = .vertical
        st.distribution = .fill
        st.spacing = 16
        return st
    }()
    
    private lazy var marketcapLabelStackView: UIStackView = {
       let st = UIStackView(arrangedSubviews: [marketcapTitleLabel, marketcapSubTitleLabel])
        st.axis = .vertical
        st.distribution = .fill
        st.spacing = 4
        return st
    }()
    
    private let marketcapTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "Market Capital TOP 3"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        return label
    }()
    
    private let marketcapSubTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.text = "It's based on Closing Price."
        label.font = .systemFont(ofSize: 20, weight: .regular)
        return label
    }()
    
    private lazy var marketcapCorpStackView: UIStackView = {
       let st = UIStackView()
        st.axis = .vertical
        st.distribution = .fill
        st.spacing = 8
        return st
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .black
        
        addViews()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addViews() {
        addSubview(mainScrollView)
        mainScrollView.addSubview(mainStackView)
    }
    
    private func setConstraints() {
        mainScrollViewConstraints()
        mainStackViewConstraints()
        nasdaqCalendarViewConstraints()
        dividerViewConstraints()
    }
    
    private func mainScrollViewConstraints() {
        mainScrollView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mainScrollView.topAnchor.constraint(equalTo: topAnchor),
            mainScrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            mainScrollView.centerXAnchor.constraint(equalTo: centerXAnchor),
            mainScrollView.widthAnchor.constraint(equalTo: widthAnchor)
        ])
    }
    
    private func mainStackViewConstraints() {
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let screenWidth = UIScreen.main.bounds.size.width
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: mainScrollView.topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: mainScrollView.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: mainScrollView.trailingAnchor, constant: -16),
            mainStackView.bottomAnchor.constraint(equalTo: mainScrollView.bottomAnchor),
            mainStackView.widthAnchor.constraint(equalToConstant: CGFloat(screenWidth - 32))
        ])
    }
    
    private func nasdaqCalendarViewConstraints() {
        nasdaqCalendarView.translatesAutoresizingMaskIntoConstraints = false
        let screenWidth = UIScreen.main.bounds.size.width
        
        NSLayoutConstraint.activate([
            nasdaqCalendarView.heightAnchor.constraint(equalToConstant: CGFloat(screenWidth - 32))
        ])
    }
    
    private func dividerViewConstraints() {
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dividerView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
}
