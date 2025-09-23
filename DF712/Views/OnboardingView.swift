//
//  OnboardingView.swift
//  TaskFusion
//
//  Created by IGOR on 22/09/2025.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @AppStorage("hasViewedOnboarding") private var hasViewedOnboarding = false
    @State private var showMainApp = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color("Background"), Color("Background").opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress bar
                HStack {
                    ForEach(0..<viewModel.onboardingItems.count, id: \.self) { index in
                        Rectangle()
                            .fill(index <= viewModel.currentStep ? Color("ButtonColor") : Color.white.opacity(0.3))
                            .frame(height: 4)
                            .animation(.easeInOut(duration: 0.3), value: viewModel.currentStep)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.top, 20)
                
                Spacer()
                
                // Content
                TabView(selection: $viewModel.currentStep) {
                    ForEach(Array(viewModel.onboardingItems.enumerated()), id: \.offset) { index, item in
                        OnboardingStepView(
                            item: item,
                            isAnimating: viewModel.isAnimating
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.5), value: viewModel.currentStep)
                
                Spacer()
                
                // Navigation buttons
                HStack(spacing: 20) {
                    if viewModel.currentStep > 0 {
                        Button(action: {
                            viewModel.previousStep()
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(25)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if viewModel.isLastStep {
                            completeOnboarding()
                        } else {
                            viewModel.nextStep()
                        }
                    }) {
                        HStack {
                            Text(viewModel.isLastStep ? "Get Started" : "Next")
                            if !viewModel.isLastStep {
                                Image(systemName: "chevron.right")
                            }
                        }
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(Color("ButtonColor"))
                        .cornerRadius(25)
                        .shadow(color: Color("ButtonColor").opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            viewModel.startAnimation()
        }
        .fullScreenCover(isPresented: $showMainApp) {
            ContentView()
        }
    }
    
    private func completeOnboarding() {
        hasViewedOnboarding = true
        showMainApp = true
    }
}

struct OnboardingStepView: View {
    let item: OnboardingItem
    let isAnimating: Bool
    
    var body: some View {
        VStack(spacing: 40) {
            // Icon with animation
            ZStack {
                Circle()
                    .fill(Color("ButtonColor").opacity(0.2))
                    .frame(width: 120, height: 120)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                
                Image(systemName: item.systemImage)
                    .font(.system(size: 50, weight: .light))
                    .foregroundColor(Color("ButtonColor"))
                    .rotationEffect(.degrees(isAnimating ? 5 : -5))
            }
            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
            
            VStack(spacing: 16) {
                Text(item.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(item.description)
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(item.details.enumerated()), id: \.offset) { index, detail in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color("ButtonColor"))
                            .font(.system(size: 16))
                        
                        Text(detail)
                            .foregroundColor(.white.opacity(0.9))
                            .font(.body)
                    }
                    .opacity(isAnimating ? 1.0 : 0.7)
                    .animation(.easeInOut(duration: 1.5).delay(Double(index) * 0.2), value: isAnimating)
                }
            }
            .padding(.horizontal, 40)
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    OnboardingView()
}
