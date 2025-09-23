//
//  SettingsView.swift
//  TaskFusion
//
//  Created by IGOR on 22/09/2025.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: TaskViewModel
    @State private var showingResetAlert = false
    
    private var taskService: TaskService {
        viewModel.taskService
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Statistics Section
                        statisticsSection
                        
                        // Data Management
                        dataManagementSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .alert("Reset All Data", isPresented: $showingResetAlert) {
            Button("Cancel") { }
            Button("Reset") {
                resetAllData()
            }
        } message: {
            Text("This will delete all your tasks and reset all settings. This action cannot be undone.")
        }
    }
    
    
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Statistics")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 16) {
                StatRow(
                    icon: "checkmark.circle.fill",
                    label: "Tasks Completed",
                    value: "\(taskService.completedTasksCount)",
                    color: Color("ButtonColor")
                )
                
                StatRow(
                    icon: "circle",
                    label: "Pending Tasks",
                    value: "\(taskService.pendingTasksCount)",
                    color: .white.opacity(0.7)
                )
                
                StatRow(
                    icon: "flame.fill",
                    label: "Current Streak",
                    value: "\(taskService.currentStreak) days",
                    color: .orange
                )
                
                StatRow(
                    icon: "percent",
                    label: "Completion Rate",
                    value: "\(Int(taskService.completionRate * 100))%",
                    color: Color("ButtonColor")
                )
                
                if !taskService.overdueTasks.isEmpty {
                    StatRow(
                        icon: "exclamationmark.triangle.fill",
                        label: "Overdue Tasks",
                        value: "\(taskService.overdueTasks.count)",
                        color: .red
                    )
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var dataManagementSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Data Management")
                .font(.headline)
                .foregroundColor(.white)
            
            Button(action: { showingResetAlert = true }) {
                HStack {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .frame(width: 24)
                    
                    Text("Reset All Data")
                        .foregroundColor(.red)
                    
                    Spacer()
                }
                .padding(.vertical, 8)
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    
    private func resetAllData() {
        // Clear all tasks
        taskService.tasks.removeAll()
        
        // Reset UserDefaults
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "SavedTasks")
    }
}

struct StatRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(label)
                .foregroundColor(.white)
            
            Spacer()
            
            Text(value)
                .foregroundColor(color)
                .fontWeight(.semibold)
        }
    }
}


#Preview {
    SettingsView()
        .environmentObject(TaskViewModel())
}
