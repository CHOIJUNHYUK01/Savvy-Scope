// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? JSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation

// MARK: - Welcome
struct NasdaqData: Codable {
    let todayData: TodayData
    let prevDataList: [PrevDataList]

    enum CodingKeys: String, CodingKey {
        case todayData = "output1"
        case prevDataList = "output2"
    }
}

// MARK: - Today Data
struct TodayData: Codable {
    let todayRate: String

    enum CodingKeys: String, CodingKey {
        case todayRate = "prdy_ctrt" // 전일 대비율
    }
}

// MARK: - Last 30 Days Data
struct PrevDataList: Codable {
    let stockDate, stockValue: String

    enum CodingKeys: String, CodingKey {
        case stockDate = "stck_bsop_date" // 날짜
        case stockValue = "ovrs_nmix_prpr" // 날짜에 따른 값
    }
}
