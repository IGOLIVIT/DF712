//
//  OnboardingViewModel.swift
//  TaskFusion
//
//  Created by IGOR on 22/09/2025.
//

import Foundation
import SwiftUI
import Combine

class OnboardingViewModel: ObservableObject {
    @Published var currentStep = 0
    @Published var isAnimating = false
    
    let onboardingItems = OnboardingItem.onboardingSteps
    
    var isLastStep: Bool {
        currentStep == onboardingItems.count - 1
    }
    
    var progress: Double {
        Double(currentStep + 1) / Double(onboardingItems.count)
    }
    
    func nextStep() {
        withAnimation(.easeInOut(duration: 0.5)) {
            if currentStep < onboardingItems.count - 1 {
                currentStep += 1
            }
        }
    }
    
    func previousStep() {
        withAnimation(.easeInOut(duration: 0.5)) {
            if currentStep > 0 {
                currentStep -= 1
            }
        }
    }
    
    func goToStep(_ step: Int) {
        withAnimation(.easeInOut(duration: 0.5)) {
            currentStep = min(max(0, step), onboardingItems.count - 1)
        }
    }
    
    func startAnimation() {
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            isAnimating = true
        }
    }
    
    func stopAnimation() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isAnimating = false
        }
    }
}
