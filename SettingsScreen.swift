import SwiftUI

struct SettingsScreen: View {
    @Binding var appearanceRaw: String
    let onOpenAnime: () -> Void
    let onReload: () -> Void

    private var appearance: Binding<AppAppearance> {
        Binding(
            get: { AppAppearance(rawValue: appearanceRaw) ?? .system },
            set: { appearanceRaw = $0.rawValue }
        )
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 7) {
                    Text("Настройки")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                    Text("TG Anime Glass")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 18)

                settingsCard {
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15, style: .continuous)
                                .fill(LinearGradient(colors: [.purple, .blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 48, height: 48)
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 21, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Telegram Web")
                                .font(.headline)
                            Text("Вход в твой Telegram-аккаунт")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button(action: onReload) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 15, weight: .semibold))
                                .frame(width: 38, height: 38)
                                .background(.thinMaterial, in: Circle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Перезагрузить Telegram")
                    }
                }

                settingsCard {
                    VStack(alignment: .leading, spacing: 13) {
                        Label("Внешний вид", systemImage: "circle.lefthalf.filled")
                            .font(.headline)
                        Picker("Оформление", selection: appearance) {
                            ForEach(AppAppearance.allCases) { option in
                                Text(option.title).tag(option)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }

                settingsCard {
                    VStack(alignment: .leading, spacing: 14) {
                        Label("Anime-вкладка", systemImage: "sparkles")
                            .font(.headline)
                        Text("Быстрый переход к боту, который открывает Anime-вкладка исходного Android-мода.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Button(action: onOpenAnime) {
                            HStack {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("Открыть @qanimebot")
                                        .font(.subheadline.weight(.semibold))
                                    Text("Перейти в Telegram")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .padding(13)
                            .background(Color.accentColor.opacity(0.10), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }

                settingsCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("О приложении", systemImage: "info.circle")
                            .font(.headline)
                        infoRow("Клиент", value: "TG Anime Glass")
                        infoRow("Платформа", value: "iOS · SwiftUI")
                        infoRow("Чаты", value: "Telegram Web K")
                        infoRow("Версия оболочки", value: "1.0")
                    }
                }

                Text("Вход и переписка работают через Telegram Web. Данные авторизации хранятся в постоянном локальном хранилище WKWebView на этом устройстве. Это самостоятельная iOS-оболочка, а не официальный клиент Telegram.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 4)
                    .padding(.bottom, 22)
            }
            .padding(.horizontal, 20)
        }
    }

    @ViewBuilder
    private func settingsCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            content()
        }
        .padding(17)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            if #available(iOS 26.0, *) {
                RoundedRectangle(cornerRadius: 23, style: .continuous)
                    .fill(.clear)
                    .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 23, style: .continuous))
            } else {
                RoundedRectangle(cornerRadius: 23, style: .continuous)
                    .fill(.ultraThinMaterial)
            }
        }
        .overlay(RoundedRectangle(cornerRadius: 23, style: .continuous).stroke(.white.opacity(0.18), lineWidth: 0.8))
    }

    private func infoRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title).foregroundStyle(.secondary)
            Spacer()
            Text(value).foregroundStyle(.primary)
        }
        .font(.subheadline)
    }
}
