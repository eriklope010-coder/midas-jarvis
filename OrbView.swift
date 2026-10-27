import SwiftUI

struct OrbView: View {
    var active: Bool = false
    @State private var pulse = false
    @State private var spin = false

    var body: some View {
        ZStack {
            Circle()
                .fill(.black)
                .overlay(Circle().stroke(MidasTheme.gold.opacity(0.25), lineWidth: 1))
                .shadow(color: MidasTheme.gold.opacity(active ? 0.9 : 0.45), radius: active ? 34 : 18)

            Circle()
                .trim(from: 0.05, to: 0.72)
                .stroke(
                    AngularGradient(colors: [.clear, MidasTheme.deepGold, MidasTheme.gold, .white.opacity(0.85), MidasTheme.gold, .clear], center: .center),
                    style: StrokeStyle(lineWidth: 7, lineCap: .round)
                )
                .padding(9)
                .rotationEffect(.degrees(spin ? 360 : 0))

            Circle()
                .trim(from: 0.12, to: 0.55)
                .stroke(MidasTheme.gold.opacity(0.65), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .padding(25)
                .rotationEffect(.degrees(spin ? -360 : 0))

            Circle()
                .fill(RadialGradient(colors: [MidasTheme.gold.opacity(0.28), .clear], center: .center, startRadius: 0, endRadius: 70))
                .scaleEffect(pulse ? 1.14 : 0.88)
        }
        .onAppear {
            withAnimation(.linear(duration: active ? 3.5 : 7).repeatForever(autoreverses: false)) { spin = true }
            withAnimation(.easeInOut(duration: active ? 0.7 : 1.8).repeatForever(autoreverses: true)) { pulse = true }
        }
        .accessibilityLabel(active ? "Midas escuchando" : "Orbe Midas")
    }
}
