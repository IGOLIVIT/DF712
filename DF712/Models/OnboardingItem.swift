//
//  OnboardingItem.swift
//  TaskFusion
//
//  Created by IGOR on 22/09/2025.
//

import Foundation

struct OnboardingItem: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let systemImage: String
    let details: [String]
    
    static let onboardingSteps = [
        OnboardingItem(
            name: "Welcome to TaskFusion",
            description: "Your ultimate productivity companion with gamified task management",
            systemImage: "star.fill",
            details: [
                "Organize your tasks efficiently",
                "Track your productivity progress",
                "Earn rewards for completing goals"
            ]
        ),
        OnboardingItem(
            name: "Gamified Experience",
            description: "Complete tasks to earn milestones, badges, and unlock achievements",
            systemImage: "gamecontroller.fill",
            details: [
                "Visual progress tracking",
                "Achievement badges",
                "Productivity streaks",
                "Level up your focus"
            ]
        ),
        OnboardingItem(
            name: "Focus Timer",
            description: "Built-in Pomodoro timer with beautiful animations to enhance your focus",
            systemImage: "timer",
            details: [
                "25-minute focus sessions",
                "5-minute breaks",
                "Customizable intervals",
                "Track time spent on tasks"
            ]
        ),
        OnboardingItem(
            name: "Smart Suggestions",
            description: "AI-driven task prioritization based on your productivity patterns",
            systemImage: "brain.head.profile",
            details: [
                "Intelligent task sorting",
                "Deadline awareness",
                "Priority recommendations",
                "Personalized insights"
            ]
        )
    ]
}
