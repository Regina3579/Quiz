//
//  SettingsView.swift
//  QuizApp
//
//  Sound settings, for a parent as much as a child.
//
//  Music and sound effects get a switch each rather than sharing one, because
//  they answer different complaints: one child is distracted by a tune playing
//  under a question, another is in a quiet room and only wants the chimes
//  gone. The slider is there for the case in between — music welcome, but
//  quieter than the default.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage(AudioSettings.musicKey) private var musicOn = true
    @AppStorage(AudioSettings.effectsKey) private var effectsOn = true
    @AppStorage(AudioSettings.musicVolumeKey) private var musicVolume = 1.0

    private let ink = Color(red: 0.30, green: 0.17, blue: 0.05)

    var body: some View {
        ZStack {
            LinearGradient(colors: [
                Color(red: 0.99, green: 0.94, blue: 0.80),
                Color(red: 0.95, green: 0.86, blue: 0.66)
            ], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    header

                    toggleRow(icon: "🎵",
                              title: "Music",
                              detail: "A gentle tune while you play",
                              isOn: $musicOn)

                    if musicOn { volumeRow }

                    toggleRow(icon: "🔔",
                              title: "Sound Effects",
                              detail: "Chimes, page turns and taps",
                              isOn: $effectsOn)

                    note
                    doneButton
                }
                .padding(20)
            }
        }
        .onChange(of: musicOn) { _ in Music.shared.applySettings() }
        .onChange(of: musicVolume) { _ in Music.shared.applySettings() }
    }

    private var header: some View {
        VStack(spacing: 5) {
            Text("⚙️").font(.system(size: 42))
            Text("Sound")
                .font(Theme.display(28))
                .foregroundColor(ink)
        }
        .padding(.top, 26)
        .padding(.bottom, 4)
    }

    private func toggleRow(icon: String, title: String, detail: String,
                           isOn: Binding<Bool>) -> some View {
        HStack(spacing: 13) {
            Text(icon).font(.system(size: 27))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Theme.bold(18))
                    .foregroundColor(ink)
                Text(detail)
                    .font(Theme.medium(13))
                    .foregroundColor(ink.opacity(0.65))
            }

            Spacer(minLength: 8)

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(Color(red: 0.36, green: 0.70, blue: 0.40))
        }
        .padding(15)
        .background(card)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(detail)")
    }

    private var volumeRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Text("🔉").font(.system(size: 19))
                Text("How loud")
                    .font(Theme.bold(16))
                    .foregroundColor(ink)
                Spacer()
                Text("\(Int(musicVolume * 100))%")
                    .font(Theme.bold(15))
                    .foregroundColor(ink.opacity(0.7))
                    .contentTransition(.numericText())
            }

            Slider(value: $musicVolume, in: 0.1...1)
                .tint(Color(red: 0.85, green: 0.55, blue: 0.20))
        }
        .padding(15)
        .background(card)
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.2), value: musicOn)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Music volume, \(Int(musicVolume * 100)) percent")
    }

    private var note: some View {
        HStack(alignment: .top, spacing: 9) {
            Text("💡").font(.system(size: 15))
            Text("The music always sits well under the questions, and drops "
                 + "back on its own whenever anything is being read aloud.")
                .font(Theme.medium(13))
                .foregroundColor(ink.opacity(0.7))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white.opacity(0.45))
        )
    }

    private var doneButton: some View {
        Button {
            Haptics.play(.light)
            dismiss()
        } label: {
            Text("Done")
                .font(Theme.bold(18))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color(red: 0.60, green: 0.44, blue: 0.22))
                )
                .shadow(color: .black.opacity(0.22), radius: 6, y: 3)
        }
        .buttonStyle(PressableButtonStyle())
        .padding(.top, 4)
    }

    private var card: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(.white.opacity(0.75))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color(red: 0.72, green: 0.55, blue: 0.28), lineWidth: 1.5)
            )
    }
}

#Preview {
    SettingsView()
}
