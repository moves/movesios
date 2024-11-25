//
//  ReportVideoRequest.swift
// //
//
//  Created by Wasiq Tayyab on 23/09/2024.
//

import Foundation

struct ReportVideoRequest: Codable {
    let userId: Int
    let videoId: Int
    let reportReasonId: Int
    let description: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case videoId = "video_id"
        case reportReasonId = "report_reason_id"
        case description = "description"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try container.encode(videoId, forKey: .videoId)
        try container.encode(reportReasonId, forKey: .reportReasonId)
        if !description.isEmpty {
            try container.encode(description, forKey: .description)
        }
    }
}
