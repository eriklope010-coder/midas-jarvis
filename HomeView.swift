import SwiftUI

struct HomeView: View {
    @State private var inCall = false
    @StateObject private var assistant = VoiceAssistant()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            if inCall { callView } else { homeView }
        }
        .preferredColorScheme(.dark)
    }

    private var homeView: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 55)
            OrbView(active: false)
                .frame(width: 205, height: 205)
            Text("MIDAS")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .tracking(7)
                .foregroundStyle(MidasTheme.gold.opacity(0.8))
                .padding(.top, 24)
            Spacer()
            Button {
                withAnimation(.easeInOut(duration: 0.25)) { inCall = true }
                Task { await assistant.start() }
            } label: {
                Label("Llamar a Midas", systemImage: "phone.fill")
                    .font(.headline)
                    .foregroundStyle(.black)
                    .padding(.horizontal, 28).padding(.vertical, 15)
                    .background(Capsule().fill(MidasTheme.gold))
                    .shadow(color: MidasTheme.gold.opacity(0.35), radius: 16)
            }
            .padding(.bottom, 34)
            AppLauncher()
                .padding(.horizontal, 14)
                .padding(.bottom, 26)
        }
    }

    private var callView: some View {
        VStack {
            Spacer()
            Button {
                assistant.stop()
                withAnimation(.easeInOut(duration: 0.25)) { inCall = false }
            } label: {
                OrbView(active: assistant.isListening || assistant.isThinking)
                    .frame(width: 270, height: 270)
            }
            .buttonStyle(.plain)
            Spacer()
        }
        .contentShape(Rectangle())
        .accessibilityHint("Toca el orbe para terminar la llamada")
    }
}
