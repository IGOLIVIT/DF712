//
//  TaskDetailView.swift
//  TaskFusion
//
//  Created by IGOR on 22/09/2025.
//

import SwiftUI

struct TaskDetailView: View {
    let task: Task
    @ObservedObject var viewModel: TaskViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isEditing = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Task header
                        taskHeader
                        
                        // Focus timer section
                        focusTimerSection
                        
                        // Task details
                        taskDetailsSection
                        
                        // Progress section
                        progressSection
                        
                        // Actions section
                        actionsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("Task Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        print("DEBUG: Closing TaskDetailView for task: \(task.title)")
                        viewModel.selectedTask = nil
                        viewModel.showingTaskDetail = false
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Edit", action: { 
                            print("DEBUG: Edit button tapped")
                            isEditing = true 
                        })
                        Button("Delete", action: { 
                            print("DEBUG: Delete menu button tapped - showing alert")
                            showingDeleteAlert = true 
                        })
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            EditTaskView(task: .constant(task), viewModel: viewModel)
        }
        .alert("Delete Task", isPresented: $showingDeleteAlert) {
            Button("Cancel") { 
                print("DEBUG: Delete alert cancelled")
            }
            Button("Delete") {
                print("DEBUG: Delete alert confirmed - deleting task")
                viewModel.deleteTask(task)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this task? This action cannot be undone.")
        }
    }
    
    private var taskHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                Button(action: {
                    withAnimation(.spring()) {
                        viewModel.toggleTaskCompletion(task)
                    }
                }) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title)
                        .foregroundColor(task.isCompleted ? Color("ButtonColor") : .white.opacity(0.6))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(task.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .strikethrough(task.isCompleted)
                    
                    if !task.description.isEmpty {
                        Text(task.description)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                Spacer()
                
                // Priority indicator
                VStack {
                    Circle()
                        .fill(Color(task.priority.color))
                        .frame(width: 12, height: 12)
                    
                    Text(task.priority.rawValue)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            // Tags
            if !task.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(task.tags, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.caption)
                                .foregroundColor(Color("ButtonColor"))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color("ButtonColor").opacity(0.2))
                                .cornerRadius(6)
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var focusTimerSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "timer")
                    .foregroundColor(Color("ButtonColor"))
                Text("Focus Timer")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                
                if viewModel.currentFocusTask?.id == task.id {
                    Text(viewModel.isBreakTime ? "Break Time" : "Focus Time")
                        .font(.caption)
                        .foregroundColor(Color("ButtonColor"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color("ButtonColor").opacity(0.2))
                        .cornerRadius(6)
                }
            }
            
            // Timer display
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 8)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .trim(from: 0, to: viewModel.timerProgress)
                    .stroke(
                        Color("ButtonColor"),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: viewModel.timerProgress)
                
                VStack {
                    Text(viewModel.timerDisplayText)
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    
                    Text(viewModel.isBreakTime ? "Break" : "Focus")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            // Timer controls
            HStack(spacing: 20) {
                if viewModel.isTimerRunning {
                    Button(action: { viewModel.pauseTimer() }) {
                        HStack {
                            Image(systemName: "pause.fill")
                            Text("Pause")
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(25)
                    }
                } else {
                    Button(action: { viewModel.startTimer(for: task) }) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Start")
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color("ButtonColor"))
                        .cornerRadius(25)
                    }
                }
                
                if viewModel.isTimerRunning || viewModel.focusTimeRemaining != 1500 {
                    Button(action: { viewModel.stopTimer() }) {
                        HStack {
                            Image(systemName: "stop.fill")
                            Text("Stop")
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(25)
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var taskDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Details")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                if task.dueDate != nil {
                    DetailRow(
                        icon: "calendar",
                        label: "Due Date",
                        value: task.formattedDueDate,
                        color: task.isOverdue ? .red : .white.opacity(0.7)
                    )
                }
                
                DetailRow(
                    icon: "clock",
                    label: "Estimated Time",
                    value: "\(task.estimatedMinutes) minutes",
                    color: .white.opacity(0.7)
                )
                
                if task.actualMinutes > 0 {
                    DetailRow(
                        icon: "clock.fill",
                        label: "Actual Time",
                        value: "\(task.actualMinutes) minutes",
                        color: Color("ButtonColor")
                    )
                }
                
                if let completedDate = task.completedDate {
                    DetailRow(
                        icon: "checkmark.circle.fill",
                        label: "Completed",
                        value: DateFormatter.shortDateTime.string(from: completedDate),
                        color: Color("ButtonColor")
                    )
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Progress")
                .font(.headline)
                .foregroundColor(.white)
            
            if task.estimatedMinutes > 0 && task.actualMinutes > 0 {
                let progress = min(Double(task.actualMinutes) / Double(task.estimatedMinutes), 1.0)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Time Progress")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Spacer()
                        
                        Text("\(Int(progress * 100))%")
                            .font(.body)
                            .foregroundColor(Color("ButtonColor"))
                    }
                    
                    ProgressView(value: progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: Color("ButtonColor")))
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                }
            }
            
            HStack {
                VStack {
                    Text("\(task.actualMinutes)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color("ButtonColor"))
                    
                    Text("Minutes Spent")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                VStack {
                    Text(task.isCompleted ? "100%" : "0%")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(task.isCompleted ? Color("ButtonColor") : .white.opacity(0.7))
                    
                    Text("Complete")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var actionsSection: some View {
        VStack(spacing: 12) {
            if !task.isCompleted {
                Button(action: {
                    withAnimation(.spring()) {
                        viewModel.toggleTaskCompletion(task)
                    }
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Mark as Complete")
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color("ButtonColor"))
                    .cornerRadius(12)
                }
            } else {
                Button(action: {
                    withAnimation(.spring()) {
                        viewModel.toggleTaskCompletion(task)
                    }
                }) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Mark as Incomplete")
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(12)
                }
            }
        }
    }
}

struct DetailRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(label)
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Text(value)
                .foregroundColor(color)
        }
    }
}

struct EditTaskView: View {
    @Binding var task: Task
    @ObservedObject var viewModel: TaskViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String
    @State private var description: String
    @State private var dueDate: Date
    @State private var hasDueDate: Bool
    @State private var priority: TaskPriority
    @State private var estimatedMinutes: Int
    @State private var tags: [String]
    @State private var tagText = ""
    
    init(task: Binding<Task>, viewModel: TaskViewModel) {
        self._task = task
        self.viewModel = viewModel
        
        self._title = State(initialValue: task.wrappedValue.title)
        self._description = State(initialValue: task.wrappedValue.description)
        self._dueDate = State(initialValue: task.wrappedValue.dueDate ?? Date())
        self._hasDueDate = State(initialValue: task.wrappedValue.dueDate != nil)
        self._priority = State(initialValue: task.wrappedValue.priority)
        self._estimatedMinutes = State(initialValue: task.wrappedValue.estimatedMinutes)
        self._tags = State(initialValue: task.wrappedValue.tags)
    }
    
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
            .navigationTitle("Edit Task")
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
        task.title = title
        task.description = description
        task.dueDate = hasDueDate ? dueDate : nil
        task.priority = priority
        task.estimatedMinutes = estimatedMinutes
        task.tags = tags
        
        viewModel.updateTask(task)
        dismiss()
    }
}

extension DateFormatter {
    static let shortDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}

#Preview {
    let sampleTask = Task(title: "Sample Task", description: "Sample description", dueDate: Date(), priority: .medium)
    return TaskDetailView(task: sampleTask, viewModel: TaskViewModel())
}
