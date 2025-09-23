//
//  TaskListView.swift
//  TaskFusion
//
//  Created by IGOR on 22/09/2025.
//

import SwiftUI

struct TaskListView: View {
    @EnvironmentObject var viewModel: TaskViewModel
    @State private var showingAddTask = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Gamification header
                    gamificationHeader
                    
                    // Search and filter bar
                    searchAndFilterBar
                    
                    // Smart suggestions section
                    if !viewModel.smartSuggestions.isEmpty {
                        smartSuggestionsSection
                    }
                    
                    // Tasks list
                    tasksListSection
                }
            }
            .navigationTitle("Tasks")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTask = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(Color("ButtonColor"))
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showingTaskDetail) {
            if let task = viewModel.selectedTask {
                TaskDetailView(task: task, viewModel: viewModel)
            }
        }
    }
    
    private var gamificationHeader: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Level \(viewModel.userLevel)")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("\(viewModel.taskService.completedTasksCount) tasks completed")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(viewModel.taskService.currentStreak) day streak")
                        .font(.headline)
                        .foregroundColor(Color("ButtonColor"))
                    
                    Text("\(Int(viewModel.taskService.completionRate * 100))% completion rate")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            // Progress bar to next level
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Progress to Level \(viewModel.userLevel + 1)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Text("\(Int(viewModel.progressToNextLevel * 100))%")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                ProgressView(value: viewModel.progressToNextLevel)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color("ButtonColor")))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color("Background"))
    }
    
    private var searchAndFilterBar: some View {
        VStack(spacing: 12) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.6))
                
                TextField("Search tasks...", text: $viewModel.searchText)
                    .foregroundColor(.white)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !viewModel.searchText.isEmpty {
                    Button(action: { viewModel.searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.1))
            .cornerRadius(10)
            
            // Filter options
            HStack {
                Menu {
                    Button("All Priorities") { viewModel.selectedPriority = nil }
                    ForEach(TaskPriority.allCases, id: \.self) { priority in
                        Button(priority.rawValue) { viewModel.selectedPriority = priority }
                    }
                } label: {
                    HStack {
                        Text(viewModel.selectedPriority?.rawValue ?? "All Priorities")
                        Image(systemName: "chevron.down")
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Spacer()
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
    
    private var smartSuggestionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(Color("ButtonColor"))
                Text("Smart Suggestions")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.smartSuggestions.prefix(5)) { task in
                        SmartSuggestionCard(task: task) {
                            viewModel.selectTask(task)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
    
    private var tasksListSection: some View {
        List {
            ForEach(viewModel.filteredTasks) { task in
                TaskRowView(task: task, viewModel: viewModel)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
            .onDelete(perform: deleteTasks)
        }
        .listStyle(PlainListStyle())
        .background(Color.clear)
    }
    
    private func deleteTasks(offsets: IndexSet) {
        print("DEBUG: deleteTasks called with offsets: \(offsets)")
        for index in offsets {
            let task = viewModel.filteredTasks[index]
            print("DEBUG: Deleting task via swipe: \(task.title)")
            viewModel.deleteTask(task)
        }
    }
}

struct TaskRowView: View {
    let task: Task
    @ObservedObject var viewModel: TaskViewModel
    
    var body: some View {
        HStack(spacing: 0) {
            // Completion button - very precise area
            Button(action: {
                print("DEBUG: Completion button tapped for: \(task.title)")
                withAnimation(.spring()) {
                    viewModel.toggleTaskCompletion(task)
                }
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(task.isCompleted ? Color("ButtonColor") : .white.opacity(0.6))
                    .frame(width: 32, height: 32)
                    .background(Color.clear)
            }
            .buttonStyle(PlainButtonStyle())
            .frame(width: 50, height: 60)
            .contentShape(Rectangle())
            
            // Task content area - tappable for details
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(task.title)
                        .font(.headline)
                        .foregroundColor(task.isCompleted ? .white.opacity(0.5) : .white)
                        .strikethrough(task.isCompleted)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    Spacer()
                    
                    // Priority indicator and completion status
                    HStack(spacing: 4) {
                        if task.isCompleted {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(Color("ButtonColor"))
                                .font(.caption2)
                        }
                        
                        Circle()
                            .fill(Color(task.priority.color))
                            .frame(width: 8, height: 8)
                    }
                }
                
                if !task.description.isEmpty {
                    Text(task.description)
                        .font(.body)
                        .foregroundColor(task.isCompleted ? .white.opacity(0.5) : .white.opacity(0.7))
                        .lineLimit(2)
                        .truncationMode(.tail)
                }
                
                HStack {
                    if task.dueDate != nil {
                        Label(task.formattedDueDate, systemImage: "calendar")
                            .font(.caption)
                            .foregroundColor(task.isOverdue ? .red : .white.opacity(0.6))
                    }
                    
                    if !task.tags.isEmpty {
                        ForEach(task.tags.prefix(2), id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.caption)
                                .foregroundColor(Color("ButtonColor"))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color("ButtonColor").opacity(0.2))
                                .cornerRadius(4)
                        }
                    }
                    
                    Spacer()
                    
                    if task.estimatedMinutes > 0 {
                        Label("\(task.estimatedMinutes)m", systemImage: "clock")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            .onTapGesture {
                print("DEBUG: Task content tapped - opening details for: \(task.title)")
                viewModel.selectTask(task)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(task.isCompleted ? Color("ButtonColor").opacity(0.1) : Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

struct SmartSuggestionCard: View {
    let task: Task
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(Color(task.priority.color))
                    .frame(width: 8, height: 8)
                
                Text(task.priority.rawValue)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
            }
            
            Text(task.title)
                .font(.headline)
                .foregroundColor(.white)
                .lineLimit(2)
            
            if task.dueDate != nil {
                Text(task.formattedDueDate)
                    .font(.caption)
                    .foregroundColor(task.isOverdue ? .red : Color("ButtonColor"))
            }
        }
        .padding(12)
        .frame(width: 200)
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
        .onTapGesture(perform: onTap)
    }
}

struct AddTaskView: View {
    @ObservedObject var viewModel: TaskViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var dueDate = Date()
    @State private var hasDueDate = false
    @State private var priority = TaskPriority.medium
    @State private var estimatedMinutes = 30
    @State private var tagText = ""
    @State private var tags: [String] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Basic Info Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Task Information")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            VStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    if title.isEmpty {
                                        Text("e.g. Review project proposal")
                                            .foregroundColor(.white.opacity(0.6))
                                            .font(.body)
                                            .padding(.horizontal, 16)
                                            .padding(.top, 12)
                                    }
                                    TextField("Task title", text: $title)
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.white.opacity(0.1))
                                        .cornerRadius(8)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    if description.isEmpty {
                                        Text("Add details about what needs to be done...")
                                            .foregroundColor(.white.opacity(0.6))
                                            .font(.body)
                                            .padding(.horizontal, 16)
                                            .padding(.top, 12)
                                    }
                                    TextField("Description (optional)", text: $description)
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.white.opacity(0.1))
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding(20)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(16)
                        
                        // Due Date Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Due Date")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            VStack(spacing: 12) {
                                Toggle("Set due date", isOn: $hasDueDate)
                                    .foregroundColor(.white)
                                
                                if hasDueDate {
                                    DatePicker("Due date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                                        .foregroundColor(.white)
                                        .accentColor(Color("ButtonColor"))
                                }
                            }
                        }
                        .padding(20)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(16)
                        
                        // Priority Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Priority")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Picker("Priority", selection: $priority) {
                                ForEach(TaskPriority.allCases, id: \.self) { priority in
                                    HStack {
                                        Circle()
                                            .fill(Color(priority.color))
                                            .frame(width: 8, height: 8)
                                        Text(priority.rawValue)
                                    }
                                    .tag(priority)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        .padding(20)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(16)
                        
                        // Estimated Time Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Estimated Time")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Stepper("\(estimatedMinutes) minutes", value: $estimatedMinutes, in: 5...480, step: 5)
                                .foregroundColor(.white)
                        }
                        .padding(20)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(16)
                        
                        // Tags Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Tags")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            VStack(spacing: 12) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        if tagText.isEmpty {
                                            Text("e.g. work, urgent, personal")
                                                .foregroundColor(.white.opacity(0.6))
                                                .font(.body)
                                                .padding(.horizontal, 16)
                                                .padding(.top, 12)
                                        }
                                        TextField("Add tag", text: $tagText)
                                            .foregroundColor(.white)
                                            .padding()
                                            .background(Color.white.opacity(0.1))
                                            .cornerRadius(8)
                                            .onSubmit {
                                                addTag()
                                            }
                                    }
                                    
                                    Button("Add", action: addTag)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(Color("ButtonColor"))
                                        .cornerRadius(8)
                                }
                                
                                if !tags.isEmpty {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack {
                                            ForEach(tags, id: \.self) { tag in
                                                HStack {
                                                    Text("#\(tag)")
                                                    Button(action: { removeTag(tag) }) {
                                                        Image(systemName: "xmark")
                                                            .font(.caption)
                                                    }
                                                }
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color("ButtonColor").opacity(0.2))
                                                .foregroundColor(Color("ButtonColor"))
                                                .cornerRadius(8)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTask()
                    }
                    .foregroundColor(Color("ButtonColor"))
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func addTag() {
        let trimmedTag = tagText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTag.isEmpty && !tags.contains(trimmedTag) {
            tags.append(trimmedTag)
            tagText = ""
        }
    }
    
    private func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }
    
    private func saveTask() {
        viewModel.addTask(
            title: title,
            description: description,
            dueDate: hasDueDate ? dueDate : nil,
            priority: priority,
            estimatedMinutes: estimatedMinutes,
            tags: tags
        )
        dismiss()
    }
}

#Preview {
    TaskListView()
        .environmentObject(TaskViewModel())
}
