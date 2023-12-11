//
//  AnalysisResponseModel.swift
//  test
//
//  Created by ZhZinekenov on 27.11.2023.
//

import Foundation

struct Response: Decodable {
    let totalMinutesSpentInAMood: [String: Int]
    let pleasantTimeRangesForTasksCompletions: [String: [(String, String)]]
    let recommendedTasks: [String: [String]]
    let avoidTasks: [String: [String]]
    let exerciseRecommendations: [String: String]
    let motivation: [String: String]

    private struct TimeRange: Decodable {
        let start: String
        let end: String
    }

    enum CodingKeys: String, CodingKey {
        case totalMinutesSpentInAMood = "Productive Minutes per Mood"
        case pleasantTimeRangesForTasksCompletions = "Pleasant Time Ranges for Tasks Completions"
        case recommendedTasks = "Recommended Tasks"
        case avoidTasks = "Avoid Tasks"
        case exerciseRecommendations = "Exercise Recommendations"
        case motivation = "Motivation"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        totalMinutesSpentInAMood = try container.decode([String: Int].self, forKey: .totalMinutesSpentInAMood)

        // Decode the entire dictionary for "Pleasant Time Ranges for Tasks Completions"
        let rangesContainer = try container.decode([String: [TimeRange]].self, forKey: .pleasantTimeRangesForTasksCompletions)

        // Process the dictionary manually to convert TimeRange to (String, String)
        pleasantTimeRangesForTasksCompletions = rangesContainer.mapValues { timeRanges in
            timeRanges.map { ($0.start, $0.end) }
        }

        recommendedTasks = try container.decode([String: [String]].self, forKey: .recommendedTasks)
        avoidTasks = try container.decode([String: [String]].self, forKey: .avoidTasks)
        exerciseRecommendations = try container.decode([String: String].self, forKey: .exerciseRecommendations)
        motivation = try container.decode([String: String].self, forKey: .motivation)
    }
}



