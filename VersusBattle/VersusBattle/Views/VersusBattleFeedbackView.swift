import SwiftUI

struct VersusBattleFeedbackView: View {
    @Binding var isPresented: Bool
    @State private var versusBattleFeedbackType: VersusBattleFeedbackType = .general
    @State private var versusBattleFeedbackText: String = ""
    @State private var versusBattleUserRating: Int = 5
    @State private var versusBattleUserEmail: String = ""
    @State private var versusBattleShowThankYou: Bool = false
    
    var body: some View {
        ZStack {
            // Background image (subtle)
            Image("versback")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .ignoresSafeArea()
            
            // Background overlay
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            // Feedback dialog
            versusBattleFeedbackDialog
        }
        .overlay(versusBattleThankYouOverlay)
    }
    
    private var versusBattleFeedbackDialog: some View {
        VStack(spacing: 0) {
            versusBattleFeedbackHeader
            versusBattleFeedbackContent
            versusBattleFeedbackButtons
        }
        .frame(maxWidth: 500)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
        .padding(20)
    }
    
    private var versusBattleFeedbackHeader: some View {
        VStack(spacing: 12) {
            HStack {
                Text("📝 Feedback")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            Text("Help us improve Mahjong Versus!")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 16)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    private var versusBattleFeedbackContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                versusBattleRatingSection
                versusBattleFeedbackTypeSection
                versusBattleFeedbackTextSection
                versusBattleEmailSection
                versusBattleContactInfoSection
            }
            .padding(24)
        }
        .background(Color(.systemBackground))
    }
    
    private var versusBattleRatingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Rate Your Experience")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { star in
                    Button(action: {
                        versusBattleUserRating = star
                    }) {
                        Image(systemName: star <= versusBattleUserRating ? "star.fill" : "star")
                            .font(.title2)
                            .foregroundColor(star <= versusBattleUserRating ? .yellow : .gray)
                    }
                }
                
                Spacer()
                
                Text("\(versusBattleUserRating)/5")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var versusBattleFeedbackTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Feedback Type")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 8) {
                ForEach(VersusBattleFeedbackType.allCases, id: \.self) { type in
                    versusBattleFeedbackTypeButton(for: type)
                }
            }
        }
    }
    
    private func versusBattleFeedbackTypeButton(for type: VersusBattleFeedbackType) -> some View {
        Button(action: {
            versusBattleFeedbackType = type
        }) {
            HStack {
                Image(systemName: versusBattleFeedbackType == type ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(versusBattleFeedbackType == type ? .blue : .gray)
                
                Text(type.title)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(versusBattleFeedbackType == type ? Color.blue.opacity(0.1) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(versusBattleFeedbackType == type ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
    
    private var versusBattleFeedbackTextSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Feedback")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(versusBattleFeedbackType.placeholder)
                .font(.caption)
                .foregroundColor(.secondary)
            
            TextEditor(text: $versusBattleFeedbackText)
                .frame(minHeight: 120)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                )
        }
    }
    
    private var versusBattleEmailSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Email (Optional)")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Leave your email if you'd like us to follow up")
                .font(.caption)
                .foregroundColor(.secondary)
            
            TextField("your@email.com", text: $versusBattleUserEmail)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
        }
    }
    
    private var versusBattleContactInfoSection: some View {
        VStack(spacing: 16) {
            Divider()
            
            Text("Other Ways to Reach Us")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.blue)
                    Text("feedback@majongversus.com")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    Spacer()
                }
                
                HStack {
                    Image(systemName: "globe")
                        .foregroundColor(.green)
                    Text("www.majongversus.com")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    Spacer()
                }
                
                HStack {
                    Image(systemName: "message.fill")
                        .foregroundColor(.purple)
                    Text("Follow us on social media for updates!")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    Spacer()
                }
            }
            .padding(.horizontal, 8)
        }
    }
    
    private var versusBattleFeedbackButtons: some View {
        VStack(spacing: 12) {
            VersusBattleButton(
                title: "Submit Feedback",
                style: .primary,
                isEnabled: !versusBattleFeedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ) {
                versusBattleSubmitFeedback()
            }
            
            VersusBattleButton(
                title: "Cancel",
                style: .secondary
            ) {
                isPresented = false
            }
        }
        .padding(24)
        .background(Color(.systemBackground))
    }
    
    private var versusBattleThankYouOverlay: some View {
        Group {
            if versusBattleShowThankYou {
                VersusBattleAlert(
                    title: "Thank You! 🙏",
                    message: "Your feedback has been received! We appreciate you taking the time to help us improve Mahjong Versus.",
                    isPresented: $versusBattleShowThankYou,
                    primaryButton: VersusBattleAlertButton(title: "You're Welcome!", style: .success) {
                        isPresented = false
                    }
                )
            }
        }
    }
    
    private func versusBattleSubmitFeedback() {
        // Here you would normally send the feedback to your server
        // For now, we'll just show a thank you message
        
        // Simulate API call delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            versusBattleShowThankYou = true
        }
        
        // In a real app, you might do something like:
        // versusBattleSendFeedbackToServer()
    }
}

enum VersusBattleFeedbackType: CaseIterable {
    case bug
    case feature
    case general
    case balance
    
    var title: String {
        switch self {
        case .bug:
            return "🐛 Bug Report"
        case .feature:
            return "💡 Feature Suggestion"
        case .general:
            return "💬 General Feedback"
        case .balance:
            return "⚖️ Game Balance"
        }
    }
    
    var placeholder: String {
        switch self {
        case .bug:
            return "Please describe the bug you encountered, including steps to reproduce it..."
        case .feature:
            return "What new feature would you like to see in the game?"
        case .general:
            return "Share your thoughts about the game..."
        case .balance:
            return "Tell us about any game balance issues you've noticed..."
        }
    }
}

#Preview {
    VersusBattleFeedbackView(isPresented: .constant(true))
}
