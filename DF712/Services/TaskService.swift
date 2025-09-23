//
//  TaskService.swift
//  TaskFusion
//
//  Created by IGOR on 22/09/2025.
//

import Foundation
import Combine
import SwiftUI

class TaskService: ObservableObject {
    static let shared = TaskService()
    
    @Published var tasks: [Task] = []
    private let userDefaults = UserDefaults.standard
    private let tasksKey = "SavedTasks"
    
    init() {
        print("DEBUG: TaskService init called")
        loadTasks()
    }
    
    // MARK: - CRUD Operations
    
    func addTask(_ task: Task) {
        objectWillChange.send()
        tasks.append(task)
        saveTasks()
    }
    
    func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            saveTasks()
        }
    }
    
    func deleteTask(_ task: Task) {
        print("DEBUG TaskService: DELETING task: \(task.title)")
        tasks.removeAll { $0.id == task.id }
        saveTasks()
        print("DEBUG TaskService: After deletion, total tasks: \(tasks.count)")
    }
    
    func deleteTask(at indexSet: IndexSet) {
        tasks.remove(atOffsets: indexSet)
        saveTasks()
    }
    
    func toggleTaskCompletion(_ task: Task) {
        objectWillChange.send()
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            if tasks[index].isCompleted {
                tasks[index].completedDate = Date()
            } else {
                tasks[index].completedDate = nil
            }
            saveTasks()
        }
    }
    
    // MARK: - Persistence
    
    private func saveTasks() {
        print("DEBUG: Saving \(tasks.count) tasks to UserDefaults")
        if let encoded = try? JSONEncoder().encode(tasks) {
            userDefaults.set(encoded, forKey: tasksKey)
            print("DEBUG: Tasks saved successfully")
        } else {
            print("DEBUG: ERROR - Failed to encode tasks!")
        }
    }
    
    private func loadTasks() {
        print("DEBUG: Loading tasks from UserDefaults")
        if let data = userDefaults.data(forKey: tasksKey),
           let decodedTasks = try? JSONDecoder().decode([Task].self, from: data) {
            tasks = decodedTasks
            print("DEBUG: Loaded \(tasks.count) tasks successfully")
        } else {
            // Start with empty tasks for new users
            tasks = []
            print("DEBUG: No saved tasks found, starting with empty array")
        }
    }
    
    // MARK: - Analytics and Gamification
    
    var completedTasksCount: Int {
        tasks.filter { $0.isCompleted }.count
    }
    
    var pendingTasksCount: Int {
        tasks.filter { !$0.isCompleted }.count
    }
    
    var overdueTasks: [Task] {
        tasks.filter { $0.isOverdue }
    }
    
    var todaysTasks: [Task] {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        return tasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return dueDate >= today && dueDate < tomorrow
        }
    }
    
    var completionRate: Double {
        guard !tasks.isEmpty else { return 0 }
        return Double(completedTasksCount) / Double(tasks.count)
    }
    
    var currentStreak: Int {
        let calendar = Calendar.current
        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())
        
        while true {
            let tasksForDay = tasks.filter { task in
                guard let completedDate = task.completedDate else { return false }
                return calendar.isDate(completedDate, inSameDayAs: currentDate)
            }
            
            if tasksForDay.isEmpty {
                break
            }
            
            streak += 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
        }
        
        return streak
    }
    
    func getTasksByPriority() -> [TaskPriority: [Task]] {
        Dictionary(grouping: tasks.filter { !$0.isCompleted }, by: { $0.priority })
    }
    
    func getSmartSuggestions() -> [Task] {
        let now = Date()
        let urgentTasks = tasks.filter { !$0.isCompleted && $0.priority == .urgent }
        let dueSoon = tasks.filter { task in
            guard let dueDate = task.dueDate, !task.isCompleted else { return false }
            return dueDate.timeIntervalSince(now) <= 24 * 60 * 60 // Due within 24 hours
        }
        
        return Array(Set(urgentTasks + dueSoon)).sorted { task1, task2 in
            if task1.priority != task2.priority {
                return task1.priority.rawValue > task2.priority.rawValue
            }
            if let date1 = task1.dueDate, let date2 = task2.dueDate {
                return date1 < date2
            }
            return task1.title < task2.title
        }
    }
}
