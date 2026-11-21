import SwiftUI
import UIKit

@MainActor
struct ContentView: View {
    @StateObject private var session = TelegramWebSession()
    @State private var selectedTab: AppTab = .chats
    @AppStorage("tgAnimeGlass.appearance") private var appearanceRaw = AppAppearance.system.rawValue

    private var appearance: AppAppearance {
        AppAppearance(rawValue: appearanceRaw) ?? .system
    }

    var body: some View {
        ZStack {
            AppBackground()

            TelegramWebView(session: session)
                .opacity(selectedTab == .settings ? 0 : 1)
                .allowsHitTesting(selectedTab != .settings)
                .accessibilityHidden(selectedTab == .settings)

            if selectedTab == .settings {
                SettingsScreen(
                    appearanceRaw: $appearanceRaw,
                    onOpenAnime: { select(.anime) },
                    onReload: { session.reload() }
                )
                .transition(.opacity.combined(with: .move(edge: .trailing)))
            }

            if selectedTab != .settings, session.isLoading {
                VStack {
                    HStack(spacing: 8) {
                        ProgressView().controlSize(.small)
                        Text("Подключаемся…")
                            .font(.caption.weight(.medium))
                    }
                    .padding(.horizontal, 13)
                    .padding(.vertical, 9)
                    .background(.ultraThinMaterial, in: Capsule())
                    .overlay(Capsule().stroke(.white.opacity(0.16), lineWidth: 0.7))
                    .padding(.top, 12)
                    Spacer()
                }
                .transition(.opacity)
                .allowsHitTesting(false)
            }

            if selectedTab != .settings, let error = session.loadError {
                ConnectionErrorCard(message: error, onRetry: { session.reload() })
                    .padding(24)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            GlassTabBar(selection: $selectedTab)
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 7)
        }
        .preferredColorScheme(appearance.colorScheme)
        .tint(Color(red: 0.49, green: 0.40, blue: 0.94))
        .animation(.snappy(duration: 0.28), value: selectedTab)
        .onChange(of: selectedTab) { _, newValue in
            session.show(newValue)
        }
    }

    private func select(_ tab: AppTab) {
        withAnimation(.snappy(duration: 0.28)) {
            selectedTab = tab
        }
    }
}

private struct AppBackground: View {
    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
            LinearGradient(
                colors: [
                    Color(red: 0.36, green: 0.31, blue: 0.82).opacity(0.24),
                    Color(red: 0.22, green: 0.62, blue: 0.78).opacity(0.12),
                    .clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Circle()
                .fill(Color.purple.opacity(0.16))
                .frame(width: 260, height: 260)
                .blur(radius: 90)
                .offset(x: 150, y: -330)
            Circle()
                .fill(Color.cyan.opacity(0.12))
                .frame(width: 240, height: 240)
                .blur(radius: 90)
                .offset(x: -150, y: 310)
        }
        .ignoresSafeArea()
    }
}

private struct GlassTabBar: View {
    @Binding var selection: AppTab

    var body: some View {
        Group {
            if #available(iOS 26.0, *) {
                GlassEffectContainer(spacing: 12) {
                    tabButtons
                }
            } else {
                tabButtons
                    .padding(6)
                    .background(.ultraThinMaterial, in: Capsule())
                    .overlay(Capsule().stroke(.white.opacity(0.22), lineWidth: 0.8))
                    .shadow(color: .black.opacity(0.12), radius: 18, y: 8)
            }
        }
        .frame(maxWidth: 440)
        .frame(maxWidth: .infinity)
    }

    private var tabButtons: some View {
        HStack(spacing: 7) {
            ForEach(AppTab.allCases) { tab in
                Button {
                    withAnimation(.spring(response: 0.34, dampingFraction: 0.78)) {
                        selection = tab
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: tab.symbol)
                            .font(.system(size: 16, weight: .semibold))
                            .symbolRenderingMode(.hierarchical)
                        if selection == tab {
                            Text(tab.title)
                                .font(.system(size: 13, weight: .semibold))
                                .transition(.opacity.combined(with: .scale(scale: 0.86)))
                        }
                    }
                    .foregroundStyle(selection == tab ? Color.primary : Color.secondary)
                    .frame(minWidth: selection == tab ? 104 : 52, minHeight: 46)
                    .contentShape(Capsule())
                    .background {
                        if selection == tab {
                            Capsule().fill(Color.accentColor.opacity(0.13))
                        }
                    }
                    .modifier(GlassTabItemStyle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.title)
                .accessibilityAddTraits(selection == tab ? .isSelected : [])
            }
        }
        .padding(6)
        .background {
            if #available(iOS 26.0, *) {
                Capsule().fill(.clear).glassEffect(.regular, in: Capsule())
            } else {
                Capsule().fill(.ultraThinMaterial)
            }
        }
        .overlay(Capsule().stroke(.white.opacity(0.22), lineWidth: 0.8))
        .shadow(color: .black.opacity(0.12), radius: 18, y: 8)
    }
}

private struct GlassTabItemStyle: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.glassEffect(.clear.interactive(), in: Capsule())
        } else {
            content
        }
    }
}

private struct ConnectionErrorCard: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 30, weight: .medium))
                .foregroundStyle(.secondary)
            Text("Нет соединения")
                .font(.title3.weight(.semibold))
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button(action: onRetry) {
                Label("Повторить", systemImage: "arrow.clockwise")
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 18)
                    .padding(.vertical, 11)
                    .background(Color.accentColor.opacity(0.16), in: Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(24)
        .frame(maxWidth: 320)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(.white.opacity(0.2), lineWidth: 0.8))
    }
}

#Preview {
    ContentView()
}
