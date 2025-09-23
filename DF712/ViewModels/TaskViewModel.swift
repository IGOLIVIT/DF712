//
//  TaskViewModel.swift
//  TaskFusion
//
//  Created by IGOR on 22/09/2025.
//

import Foundation
import SwiftUI
import Combine

class TaskViewModel: ObservableObject {
    @Published var taskService = TaskService.shared
    @Published var showingAddTask = false
    @Published var showingTaskDetail = false
    @Published var selectedTask: Task?
    @Published var searchText = ""
    @Published var selectedPriority: TaskPriority?
    
    // Focus Timer
    @Published var focusTimeRemaining: Int = 1500 // 25 minutes in seconds
    @Published var isTimerRunning = false
    @Published var isBreakTime = false
    @Published var currentFocusTask: Task?
    
    private var timer: Timer?
    private let focusTime = 1500 // 25 minutes
    private let breakTime = 300  // 5 minutes
    
    var filteredTasks: [Task] {
        print("DEBUG: filteredTasks called. Total tasks in service: \(taskService.tasks.count)")
        var filtered = taskService.tasks
        
        // Filter by priority
        if let priority = selectedPriority {
            filtered = filtered.filter { $0.priority == priority }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { task in
                task.title.localizedCaseInsensitiveContains(searchText) ||
                task.description.localizedCaseInsensitiveContains(searchText) ||
                task.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        return filtered.sorted { task1, task2 in
            // Completed tasks go to bottom
            if task1.isCompleted != task2.isCompleted {
                return !task1.isCompleted
            }
            
            // Sort by priority, then by due date
            if task1.priority != task2.priority {
                return task1.priority.rawValue > task2.priority.rawValue
            }
            
            if let date1 = task1.dueDate, let date2 = task2.dueDate {
                return date1 < date2
            }
            
            return task1.title < task2.title
        }
    }
    
    var todaysTasks: [Task] {
        taskService.todaysTasks
    }
    
    var overdueTasks: [Task] {
        taskService.overdueTasks
    }
    
    var smartSuggestions: [Task] {
        let suggestions = taskService.getSmartSuggestions()
        
        // If no smart suggestions, show recent incomplete tasks
        if suggestions.isEmpty {
            return taskService.tasks
                .filter { !$0.isCompleted }
                .sorted { task1, task2 in
                    // Sort by priority first
                    if task1.priority != task2.priority {
                        return task1.priority.rawValue > task2.priority.rawValue
                    }
                    // Then by due date (tasks with dates first)
                    if let date1 = task1.dueDate, let date2 = task2.dueDate {
                        return date1 < date2
                    }
                    if task1.dueDate != nil && task2.dueDate == nil {
                        return true
                    }
                    if task1.dueDate == nil && task2.dueDate != nil {
                        return false
                    }
                    // Finally by title
                    return task1.title < task2.title
                }
        }
        
        return suggestions
    }
    
    // MARK: - Task Management
    
    func addTask(title: String, description: String, dueDate: Date?, priority: TaskPriority, estimatedMinutes: Int = 30, tags: [String] = []) {
        let task = Task(
            title: title,
            description: description,
            dueDate: dueDate,
            priority: priority,
            estimatedMinutes: estimatedMinutes,
            tags: tags
        )
        taskService.addTask(task)
        
        // Force UI update
        objectWillChange.send()
    }
    
    func updateTask(_ task: Task) {
        taskService.updateTask(task)
    }
    
    func deleteTask(_ task: Task) {
        print("DEBUG ViewModel: DELETE called for task: \(task.title)")
        taskService.deleteTask(task)
    }
    
    func toggleTaskCompletion(_ task: Task) {
        taskService.toggleTaskCompletion(task)
        
        // Force UI update
        objectWillChange.send()
        
        // If task is completed, stop timer if it's running for this task
        if let updatedTask = taskService.tasks.first(where: { $0.id == task.id }),
           updatedTask.isCompleted && currentFocusTask?.id == task.id {
            stopTimer()
        }
    }
    
    func selectTask(_ task: Task) {
        print("DEBUG: Selecting task: \(task.title), isCompleted: \(task.isCompleted)")
        selectedTask = task
        showingTaskDetail = true
    }
    
    // MARK: - Focus Timer
    
    func startTimer(for task: Task? = nil) {
        currentFocusTask = task
        isTimerRunning = true
        focusTimeRemaining = isBreakTime ? breakTime : focusTime
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.focusTimeRemaining -= 1
            
            if self.focusTimeRemaining <= 0 {
                self.timerCompleted()
            }
        }
    }
    
    func pauseTimer() {
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func stopTimer() {
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
        focusTimeRemaining = focusTime
        isBreakTime = false
        currentFocusTask = nil
    }
    
    private func timerCompleted() {
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
        
        if isBreakTime {
            // Break completed, back to focus
            isBreakTime = false
            focusTimeRemaining = focusTime
        } else {
            // Focus session completed, start break
            if let task = currentFocusTask {
                // Add actual time to task
                var updatedTask = task
                updatedTask.actualMinutes += focusTime / 60
                updateTask(updatedTask)
            }
            
            isBreakTime = true
            focusTimeRemaining = breakTime
        }
        
        // Trigger haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    var timerDisplayText: String {
        let minutes = focusTimeRemaining / 60
        let seconds = focusTimeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var timerProgress: Double {
        let totalTime = isBreakTime ? breakTime : focusTime
        return Double(totalTime - focusTimeRemaining) / Double(totalTime)
    }
    
    // MARK: - Gamification
    
    var userLevel: Int {
        let completedTasks = taskService.completedTasksCount
        return max(1, completedTasks / 10 + 1)
    }
    
    var progressToNextLevel: Double {
        let completedTasks = taskService.completedTasksCount
        let currentLevelTasks = (userLevel - 1) * 10
        let tasksInCurrentLevel = completedTasks - currentLevelTasks
        return Double(tasksInCurrentLevel) / 10.0
    }
    
    var availableBadges: [String] {
        var badges: [String] = []
        
        if taskService.completedTasksCount >= 1 { badges.append("First Steps") }
        if taskService.completedTasksCount >= 10 { badges.append("Getting Started") }
        if taskService.completedTasksCount >= 50 { badges.append("Productive") }
        if taskService.completedTasksCount >= 100 { badges.append("Task Master") }
        if taskService.currentStreak >= 7 { badges.append("Week Warrior") }
        if taskService.currentStreak >= 30 { badges.append("Month Champion") }
        if taskService.completionRate >= 0.8 { badges.append("Efficient") }
        
        return badges
    }
}
