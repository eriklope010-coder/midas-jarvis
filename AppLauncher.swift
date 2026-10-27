import SwiftUI

struct AppShortcut: Identifiable {
    let id = UUID()
    let label: String
    let initials: String
    let scheme: String
    let fallback: String
}

struct AppLauncher: View {
    private let apps = [
        AppShortcut(label: "WhatsApp", initials: "WA", scheme: "whatsapp://", fallback: "https://www.whatsapp.com/"),
        AppShortcut(label: "TikTok", initials: "TT", scheme: "tiktok://", fallback: "https://www.tiktok.com/"),
        AppShortcut(label: "Instagram", initials: "IG", scheme: "instagram://", fallback: "https://www.instagram.com/"),
        AppShortcut(label: "Discord", initials: "DC", scheme: "discord://", fallback: "https://discord.com/app"),
        AppShortcut(label: "Spotify", initials: "SP", scheme: "spotify://", fallback: "https://open.spotify.com/")
    ]

    var body: some View {
        HStack(spacing: 12) {
            ForEach(apps) { app in
                Button { open(app) } label: {
                    VStack(spacing: 7) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(MidasTheme.gold.opacity(0.10))
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(MidasTheme.gold.opacity(0.75), lineWidth: 1))
                                .frame(width: 54, height: 54)
                            Text(app.initials)
                                .font(.system(size: 14, weight: .black, design: .rounded))
                                .foregroundStyle(MidasTheme.gold)
                        }
                        Text(app.label)
                            .font(.caption2)
                            .foregroundStyle(MidasTheme.gold.opacity(0.92))
                            .lineLimit(1)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func open(_ app: AppShortcut) {
        guard let schemeURL = URL(string: app.scheme), let fallbackURL = URL(string: app.fallback) else { return }
        UIApplication.shared.open(schemeURL, options: [:]) { ok in
            if !ok { UIApplication.shared.open(fallbackURL) }
        }
    }
}
