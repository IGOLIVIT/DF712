//
//  ContentView.swift
//  TaskFusion
//
//  Created by IGOR on 22/09/2025.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasViewedOnboarding") private var hasViewedOnboarding = false
    @StateObject private var viewModel = TaskViewModel()
    
    var body: some View {
        Group {
            if hasViewedOnboarding {
                MainTabView()
                    .environmentObject(viewModel)
            } else {
                OnboardingView()
            }
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject var viewModel: TaskViewModel
    
    var body: some View {
        TabView {
            DashboardView()
                .environmentObject(viewModel)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Dashboard")
                }
            
            TaskListView()
                .environmentObject(viewModel)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Tasks")
                }
            
            FocusView()
                .environmentObject(viewModel)
                .tabItem {
                    Image(systemName: "timer")
                    Text("Focus")
                }
            
            SettingsView()
                .environmentObject(viewModel)
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
        }
        .accentColor(Color("ButtonColor"))
        .sheet(isPresented: $viewModel.showingAddTask) {
            AddTaskView(viewModel: viewModel)
        }
    }
}

struct DashboardView: View {
    @EnvironmentObject var viewModel: TaskViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Welcome header
                        welcomeHeader
                        
                        // Quick Add Task Button
                        quickAddTaskButton
                        
                        // Quick stats
                        quickStatsSection
                        
                        // Today's tasks
                        todaysTasksSection
                        
                        // Smart suggestions (only if we have actual urgent/due soon tasks)
                        let originalSuggestions = viewModel.taskService.getSmartSuggestions()
                        if !originalSuggestions.isEmpty {
                            smartSuggestionsSection
                        }
                        
                        // Achievements
                        achievementsSection
                        
                        // Active timer (if any)
                        if viewModel.currentFocusTask != nil {
                            activeTimerSection
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("TaskFusion")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var welcomeHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Welcome back!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
                    Text("Ready to be productive today?")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(2)
                        .minimumScaleFactor(0.9)
                }
                
                Spacer()
                
                VStack {
                    Text("Level")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("\(viewModel.userLevel)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color("ButtonColor"))
                }
                .padding(12)
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color("ButtonColor").opacity(0.3), Color("ButtonColor").opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .clipped()
    }
    
    private var quickAddTaskButton: some View {
        Button(action: {
            viewModel.showingAddTask = true
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                Text("Add New Task")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.body)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color("ButtonColor"), Color("ButtonColor").opacity(0.8)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: Color("ButtonColor").opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }
    
    private var quickStatsSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            StatCard(
                icon: "checkmark.circle.fill",
                title: "Done",
                value: "\(viewModel.taskService.completedTasksCount)",
                subtitle: "tasks",
                color: Color("ButtonColor")
            )
            
            StatCard(
                icon: "clock.fill",
                title: "Todo",
                value: "\(viewModel.taskService.pendingTasksCount)",
                subtitle: "left",
                color: .orange
            )
            
            StatCard(
                icon: "flame.fill",
                title: "Streak",
                value: "\(viewModel.taskService.currentStreak)",
                subtitle: "days",
                color: .red
            )
            
            StatCard(
                icon: "percent",
                title: "Rate",
                value: "\(Int(viewModel.taskService.completionRate * 100))%",
                subtitle: "done",
                color: .green
            )
        }
    }
    
    private var todaysTasksSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: viewModel.todaysTasks.isEmpty ? "list.bullet" : "calendar.badge.clock")
                    .foregroundColor(Color("ButtonColor"))
                Text(viewModel.todaysTasks.isEmpty ? "Your Tasks" : "Today's Tasks")
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Spacer()
                
                if !viewModel.todaysTasks.isEmpty {
                    Text("\(viewModel.todaysTasks.count)")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color("ButtonColor"))
                        .cornerRadius(8)
                }
            }
            
            if viewModel.todaysTasks.isEmpty {
                // Show recent tasks if no tasks due today
                let recentTasks = viewModel.taskService.tasks.prefix(3)
                
                if recentTasks.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.5))
                        
                        Text("No tasks yet")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text("Tap 'Add New Task' to get started!")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .multilineTextAlignment(.center)
                } else {
                    ForEach(Array(recentTasks)) { task in
                        CompactTaskRow(task: task, viewModel: viewModel)
                    }
                }
            } else {
                ForEach(viewModel.todaysTasks.prefix(3)) { task in
                    CompactTaskRow(task: task, viewModel: viewModel)
                }
                
                if viewModel.todaysTasks.count > 3 {
                    HStack {
                        Spacer()
                        Text("and \(viewModel.todaysTasks.count - 3) more...")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                        Spacer()
                    }
                }
            }
        }
        .padding(20)
        .frame(minHeight: 120)
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
        .clipped()
    }
    
    private var smartSuggestionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(Color("ButtonColor"))
                Text("Smart Suggestions")
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Spacer()
            }
            
            // Only show if we have today's tasks OR if we have urgent/due soon tasks
            let originalSuggestions = viewModel.taskService.getSmartSuggestions()
            let hasActualSuggestions = !originalSuggestions.isEmpty
            
            if !hasActualSuggestions && !viewModel.todaysTasks.isEmpty {
                Text("You're all caught up! 🎉")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.7))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            } else if hasActualSuggestions {
                ForEach(originalSuggestions.prefix(2)) { task in
                    CompactTaskRow(task: task, viewModel: viewModel)
                }
            }
        }
        .padding(20)
        .frame(minHeight: 120)
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
        .clipped()
    }
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "trophy.fill")
                    .foregroundColor(Color("ButtonColor"))
                Text("Achievements")
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.availableBadges, id: \.self) { badge in
                        BadgeView(title: badge)
                    }
                    
                    if viewModel.availableBadges.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "star")
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.5))
                            Text("Complete tasks to earn badges!")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.5))
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var activeTimerSection: some View {
        VStack(spacing: 12) {
            if let currentTask = viewModel.currentFocusTask {
                Button(action: {
                    if viewModel.isTimerRunning {
                        viewModel.pauseTimer()
                    } else {
                        viewModel.startTimer(for: currentTask)
                    }
                }) {
                    HStack {
                        Image(systemName: viewModel.isTimerRunning ? "pause.circle.fill" : "play.circle.fill")
                        Text(viewModel.isTimerRunning ? "Pause Focus Session" : "Resume Focus Session")
                        Spacer()
                        Text(viewModel.timerDisplayText)
                            .font(.system(.body, design: .monospaced))
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(12)
                }
            }
        }
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                    .frame(width: 20, height: 20)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.5))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(height: 90)
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
        .clipped()
    }
}

struct CompactTaskRow: View {
    let task: Task
    @ObservedObject var viewModel: TaskViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: {
                withAnimation(.spring()) {
                    viewModel.toggleTaskCompletion(task)
                }
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? Color("ButtonColor") : .white.opacity(0.6))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.body)
                    .foregroundColor(task.isCompleted ? .white.opacity(0.6) : .white)
                    .strikethrough(task.isCompleted)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                HStack {
                    Circle()
                        .fill(Color(task.priority.color))
                        .frame(width: 6, height: 6)
                    
                    Text(task.priority.rawValue)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                        .lineLimit(1)
                    
                    if task.dueDate != nil {
                        Text("• \(task.formattedDueDate)")
                            .font(.caption)
                            .foregroundColor(task.isOverdue ? .red : .white.opacity(0.6))
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 4) {
                Button(action: {
                    viewModel.selectTask(task)
                }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.caption2)
                }
                
                Button(action: {
                    withAnimation(.spring()) {
                        viewModel.deleteTask(task)
                    }
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red.opacity(0.7))
                        .font(.caption2)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .clipped()
    }
}

struct BadgeView: View {
    let title: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "star.fill")
                .font(.title3)
                .foregroundColor(Color("ButtonColor"))
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .truncationMode(.tail)
        }
        .padding(12)
        .frame(width: 80, height: 80)
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
        .clipped()
    }
}

struct FocusView: View {
    @EnvironmentObject var viewModel: TaskViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background").ignoresSafeArea()
                
                VStack(spacing: 32) {
                    // Current task display
                    if let currentTask = viewModel.currentFocusTask {
                        VStack(spacing: 16) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Focusing on:")
                                        .font(.headline)
                                        .foregroundColor(.white.opacity(0.7))
                                    
                                    Text(currentTask.title)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    viewModel.stopTimer()
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            }
                        }
                        .padding(20)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(16)
                    }
                    
                    // Large timer display
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 12)
                            .frame(width: 280, height: 280)
                        
                        Circle()
                            .trim(from: 0, to: viewModel.timerProgress)
                            .stroke(
                                Color("ButtonColor"),
                                style: StrokeStyle(lineWidth: 12, lineCap: .round)
                            )
                            .frame(width: 280, height: 280)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 1), value: viewModel.timerProgress)
                        
                        VStack(spacing: 8) {
                            Text(viewModel.timerDisplayText)
                                .font(.system(size: 48, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                            
                            Text(viewModel.isBreakTime ? "Break Time" : "Focus Time")
                                .font(.title3)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    
                    // Timer controls
                    VStack(spacing: 16) {
                        HStack(spacing: 24) {
                            if viewModel.isTimerRunning {
                                Button(action: { viewModel.pauseTimer() }) {
                                    HStack {
                                        Image(systemName: "pause.fill")
                                        Text("Pause")
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 16)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(30)
                                }
                            } else {
                                Button(action: { viewModel.startTimer() }) {
                                    HStack {
                                        Image(systemName: "play.fill")
                                        Text("Start")
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 32)
                                    .padding(.vertical, 16)
                                    .background(Color("ButtonColor"))
                                    .cornerRadius(30)
                                }
                            }
                            
                            if viewModel.isTimerRunning || viewModel.focusTimeRemaining != 1500 {
                                Button(action: { viewModel.stopTimer() }) {
                                    HStack {
                                        Image(systemName: "stop.fill")
                                        Text("Stop")
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 16)
                                    .background(Color.red.opacity(0.8))
                                    .cornerRadius(30)
                                }
                            }
                        }
                        
                        if viewModel.currentFocusTask == nil && !viewModel.smartSuggestions.isEmpty {
                            Text("Select a task to focus on:")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.7))
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(viewModel.smartSuggestions.prefix(3)) { task in
                                        Button(action: {
                                            viewModel.currentFocusTask = task
                                        }) {
                                            VStack(alignment: .leading, spacing: 8) {
                                                Text(task.title)
                                                    .font(.headline)
                                                    .foregroundColor(.white)
                                                    .lineLimit(2)
                                                
                                                HStack {
                                                    Circle()
                                                        .fill(Color(task.priority.color))
                                                        .frame(width: 8, height: 8)
                                                    
                                                    Text(task.priority.rawValue)
                                                        .font(.caption)
                                                        .foregroundColor(.white.opacity(0.7))
                                                }
                                            }
                                            .padding(16)
                                            .frame(width: 180)
                                            .background(Color.white.opacity(0.1))
                                            .cornerRadius(12)
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 32)
            }
            .navigationTitle("Focus")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    ContentView()
}
