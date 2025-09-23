//
//  Task.swift
//  TaskFusion
//
//  Created by IGOR on 22/09/2025.
//

import Foundation

enum TaskPriority: String, CaseIterable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case urgent = "Urgent"
    
    var color: String {
        switch self {
        case .low: return "green"
        case .medium: return "YellowColor"
        case .high: return "orange"
        case .urgent: return "red"
        }
    }
}

struct Task: Identifiable, Codable, Equatable, Hashable {
    let id = UUID()
    var title: String
    var description: String
    var dueDate: Date?
    var priority: TaskPriority
    var isCompleted: Bool = false
    var completedDate: Date?
    var estimatedMinutes: Int = 30
    var actualMinutes: Int = 0
    var tags: [String] = []
    
    var isOverdue: Bool {
        guard let dueDate = dueDate else { return false }
        return !isCompleted && dueDate < Date()
    }
    
    var formattedDueDate: String {
        guard let dueDate = dueDate else { return "No due date" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: dueDate)
    }
    
    mutating func complete() {
        isCompleted = true
        completedDate = Date()
    }
    
    mutating func uncomplete() {
        isCompleted = false
        completedDate = nil
    }
}

// Sample data for development
extension Task {
    static let sampleTasks = [
        Task(title: "Review project proposal", description: "Go through the Q3 project proposal and provide feedback", dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()), priority: .high, tags: ["work", "review"]),
        Task(title: "Grocery shopping", description: "Buy ingredients for the weekend meal prep", dueDate: Calendar.current.date(byAdding: .day, value: 2, to: Date()), priority: .medium, tags: ["personal", "shopping"]),
        Task(title: "Call dentist", description: "Schedule annual checkup appointment", priority: .low, tags: ["health", "personal"]),
        Task(title: "Finish presentation", description: "Complete slides for Monday's client meeting", dueDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()), priority: .urgent, estimatedMinutes: 120, tags: ["work", "presentation"])
    ]
}
