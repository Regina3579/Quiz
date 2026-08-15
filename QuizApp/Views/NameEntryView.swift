//
//  NameEntryView.swift
//  QuizApp
//
//  A friendly welcome screen where the child types their name. It appears on
//  the very first launch and can be reopened later to change the name.
//

import SwiftUI

/// Where the player's name is stored, so every screen can greet them.
enum Player {
    static let nameKey = "quizspark.playerName"

    /// The saved name, or an empty string when none has been set yet.
    static var name: String {
        UserDefaults.standard.string(forKey: nameKey) ?? ""
    }
}

struct NameEntryView: View {
    /// The saved name (bound so typing updates it live).
    @AppStorage(Player.nameKey) private var savedName = ""

    /// Set when the child is changing an existing name rather than first launch.
    var isEditing = false

    @Environment(\.dismiss) private var dismiss
    @State private var typed = ""
    @State private var appeared = false
    @FocusState private var fieldFocused: Bool

    private let maxLength = 14

    private var trimmed: String {
        typed.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    private var canContinue: Bool { !trimmed.isEmpty }

    var body: some View {
        ZStack {
            Theme.homeBackground.ignoresSafeArea()

            VStack(spacing: 22) {
                Spacer(minLength: 0)

                Text("👋")
                    .font(.system(size: 72))
                    .scaleEffect(appeared ? 1 : 0.5)
                    .animation(.spring(response: 0.5, dampingFraction: 0.5), value: appeared)

                VStack(spacing: 8) {
                    Text(isEditing ? "Change your name" : "Welcome, explorer!")
                        .font(Theme.display(28))
                        .foregroundColor(Theme.ink)
                        .multilineTextAlignment(.center)

                    Text("What should we call you?")
                        .font(Theme.medium(16))
                        .foregroundColor(Theme.inkSoft)
                }

                nameField

                Button {
                    save()
                } label: {
                    HStack(spacing: 8) {
                        Text(isEditing ? "Save" : "Let's Go!")
                            .font(Theme.bold(19))
                        Image(systemName: "arrow.right.circle.fill").font(.title2)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(canContinue ? AnyShapeStyle(Theme.nextButton)
                                              : AnyShapeStyle(Color.gray.opacity(0.4)))
                    )
                    .shadow(color: .black.opacity(canContinue ? 0.2 : 0), radius: 8, y: 4)
                }
                .buttonStyle(PressableButtonStyle())
                .disabled(!canContinue)
                .padding(.horizontal, 30)

                if isEditing {
                    Button("Cancel") {
                        Haptics.play(.light)
                        dismiss()
                    }
                    .font(Theme.bold(15))
                    .foregroundColor(Theme.inkSoft)
                }

                Spacer(minLength: 0)
            }
            .padding(.vertical, 30)
            .opacity(appeared ? 1 : 0)
            .animation(.easeOut(duration: 0.4), value: appeared)
        }
        .onAppear {
            typed = savedName
            appeared = true
            // Give the sheet a moment to settle before raising the keyboard.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { fieldFocused = true }
        }
    }

    private var nameField: some View {
        TextField("Your name", text: $typed)
            .font(Theme.bold(22))
            .foregroundColor(Theme.ink)
            .multilineTextAlignment(.center)
            .textInputAutocapitalization(.words)
            .disableAutocorrection(true)
            .submitLabel(.done)
            .focused($fieldFocused)
            .onSubmit { if canContinue { save() } }
            .onChange(of: typed) { newValue in
                if newValue.count > maxLength {
                    typed = String(newValue.prefix(maxLength))
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Theme.jewelPink.opacity(0.5), lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.1), radius: 6, y: 3)
            .padding(.horizontal, 30)
    }

    private func save() {
        guard canContinue else { return }
        Haptics.play(.success)
        savedName = trimmed
        fieldFocused = false
        dismiss()
    }
}

#Preview {
    NameEntryView()
}
