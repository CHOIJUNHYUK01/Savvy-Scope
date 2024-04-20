//
//  MarketcapEachView.swift
//  StockSavvy
//
//  Created by CHOIJUNHYUK on 4/14/24.
//

import UIKit

class MarketcapEachView: UIView {
    
    var corpTitle: String? {
        didSet {
            guard let title = corpTitle else { return }
            corpTitleLabel.text = title
        }
    }
    
    var corpSymbol: String? {
        didSet {
            guard let symbol = corpSymbol else { return }
            corpSymbolLabel.text = symbol
        }
    }
    
    var corpMarketcap: String? {
        didSet {
            guard let marketcap = corpMarketcap else { return }
            marketcapLabel.text = marketcap
        }
    }
    
    var corpCurrentPrice: String? {
        didSet {
            guard let currentPrice = corpCurrentPrice else { return }
            currentPriceLabel.text = currentPrice
        }
    }
    
    var arise: Bool? {
        didSet {
            guard let statement = arise else {return}
            if statement {currentPriceLabel.backgroundColor = .systemRed}
            else {currentPriceLabel.backgroundColor = .systemBlue}
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(marketcapStackView)
        
        setMarketcapStackViewConstraints()
        setCorpTitleConstraints()
        setPriceStackConstraints()
    }
    
    private func setMarketcapStackViewConstraints() {
        marketcapStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            marketcapStackView.topAnchor.constraint(equalTo: topAnchor),
            marketcapStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            marketcapStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            marketcapStackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    private func setCorpTitleConstraints() {
        corpTitleStackView.layoutMargins = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 0)
        corpTitleStackView.isLayoutMarginsRelativeArrangement = true
    }
    
    private func setPriceStackConstraints() {
        priceStackView.layoutMargins = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 12)
        priceStackView.isLayoutMarginsRelativeArrangement = true
    }
    
    // MARK: StackView Wrapper
    lazy var marketcapStackView: UIStackView = {
        let st = UIStackView(arrangedSubviews: [corpTitleStackView, priceStackView])
        st.axis = .horizontal
        st.spacing = 0
        st.backgroundColor = .black
        st.distribution = .equalSpacing
        st.layer.borderColor = CGColor(red: 217, green: 217, blue: 217, alpha: 1)
        st.layer.borderWidth = 1
        st.clipsToBounds = true
        st.layer.cornerRadius = 8
        return st
    }()
    
    // MARK: Label StackView
    lazy var corpTitleStackView: UIStackView = {
        let st = UIStackView(arrangedSubviews: [corpTitleLabel, corpSymbolLabel])
        st.axis = .vertical
        st.spacing = 0
        st.distribution = .fill
        return st
    }()
    
    lazy var corpTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    lazy var  corpSymbolLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        label.textColor = .white
        return label
    }()
    
    // MARK: Price StackView
    lazy var priceStackView: UIStackView = {
        let st = UIStackView(arrangedSubviews: [currentPriceLabel, marketcapLabel])
        st.axis = .vertical
        st.spacing = 0
        st.distribution = .fill
        return st
    }()
    
    lazy var  currentPriceLabel: CurrentPriceLabel = {
        let label = CurrentPriceLabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .regular)
        label.textColor = .white
        label.textAlignment = .center
        label.clipsToBounds = true
        label.layer.cornerRadius = 8
        return label
    }()
    
    lazy var  marketcapLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .regular)
        label.textColor = .white
        label.textAlignment = .right
        return label
    }()
}

final class CurrentPriceLabel: UILabel {
    private var padding = UIEdgeInsets(top: 4.0, left: 8.0, bottom: 4.0, right: 8.0)
    
    convenience init(padding: UIEdgeInsets) {
        self.init()
        self.padding = padding
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }
    
    override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.height += padding.top + padding.bottom
        contentSize.width += padding.left + padding.right
        
        return contentSize
    }
}
