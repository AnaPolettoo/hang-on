// AcademyAI/Views/ProfileView.swift
import SwiftUI
import SwiftData

struct ProfileView: View {
    let viewModel: ProfileViewModel
    @State private var findYourColorsViewModel: FindYourColorsViewModel
    @State private var showRetakeColorimetry = false

    init(viewModel: ProfileViewModel, modelContext: ModelContext) {
        self.viewModel = viewModel
        _findYourColorsViewModel = State(initialValue: FindYourColorsViewModel(modelContext: modelContext))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                header
                paletteSection
                statsRow
                retakeButton
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 24)
        }
        .background(Theme.Color.cream)
        .fullScreenCover(isPresented: $showRetakeColorimetry, onDismiss: { viewModel.loadProfile() }) {
            RetakeColorimetryFlow(
                viewModel: findYourColorsViewModel,
                name: viewModel.profileName,
                onFinished: { showRetakeColorimetry = false }
            )
        }
    }

    private var header: some View {
        VStack(spacing: 16) {
            Text(viewModel.profileInitials)
                .font(Theme.Font.sectionTitle)
                .foregroundStyle(Theme.Color.ink)
                .frame(width: 88, height: 88)
                .background(Theme.Color.accentBorder)
                .overlay(Circle().stroke(Theme.Color.ink, lineWidth: 2))
                .clipShape(Circle())

            Text(viewModel.profileName ?? "Your name")
                .font(Theme.Font.sectionTitle)
                .foregroundStyle(Theme.Color.ink)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(Theme.Color.ink)
                        .frame(height: 2)
                        .offset(y: 6)
                }
        }
        .padding(.top, 16)
    }

    private var paletteSection: some View {
        VStack(spacing: 12) {
            if let season = viewModel.season {
                Text("MY PALETTE — \(season.displayName)".uppercased())
                    .font(Theme.Font.micro)
                    .tracking(0.5)
                    .foregroundStyle(Theme.Color.ink.opacity(0.6))
            }
            HStack(spacing: 8) {
                ForEach(Array(viewModel.paletteSwatches.enumerated()), id: \.offset) { _, color in
                    Circle()
                        .fill(swiftUIColor(color))
                        .frame(width: 44, height: 44)
                        .overlay(Circle().stroke(Theme.Color.ink, lineWidth: 2))
                }
            }
        }
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            statCard(value: "\(viewModel.checkedCount)", label: "pieces checked")
            statCard(value: "\(viewModel.closetCount)", label: "in your closet")
        }
    }

    private func statCard(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(Theme.Font.statNumber)
                .foregroundStyle(Theme.Color.ink)
            Text(label)
                .font(Theme.Font.micro)
                .foregroundStyle(Theme.Color.ink.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(18)
        .background(Color.itemBackground)
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Theme.Color.ink, lineWidth: 2)
        }
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var retakeButton: some View {
        Button {
            showRetakeColorimetry = true
        } label: {
            HStack {
                Text("Retake Colorimetry")
                    .font(Theme.Font.button)
                    .foregroundStyle(Theme.Color.ink)
                Spacer()
                Text("›")
                    .font(.system(size: 22))
                    .foregroundStyle(Theme.Color.ink.opacity(0.5))
            }
            .padding(18)
            .background(Color.itemBackground)
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Theme.Color.ink, lineWidth: 2)
            }
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func swiftUIColor(_ color: ClosetColor) -> Color {
        Color(red: color.red, green: color.green, blue: color.blue)
    }
}

private struct RetakeColorimetryFlow: View {
    let viewModel: FindYourColorsViewModel
    let name: String?
    let onFinished: () -> Void

    @State private var showResult = false

    var body: some View {
        Group {
            if showResult, let result = viewModel.result {
                PaletteResultView(
                    viewModel: PaletteResultViewModel(
                        season: result.season,
                        recommended: result.recommended,
                        avoid: result.avoid,
                        explanation: result.explanation
                    ),
                    ctaLabel: "Done",
                    onStartChecking: onFinished
                )
            } else {
                FindYourColorsView(viewModel: viewModel, name: name, onResult: { showResult = true })
            }
        }
    }
}

@MainActor
private func makeProfilePreview() -> some View {
    let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserColorimetryProfile.self, ClothingItem.self, PurchaseCheck.self, configurations: configuration)
    let context = container.mainContext

    context.insert(UserColorimetryProfile(
        name: "Ana Carolina", skinToneSample: .beige, eyeColorSample: .wine, hairColorSample: .wine,
        season: .warmAutumn, recommendedColors: [.lime, .wine, .beige, .mauve], avoidColors: []
    ))
    for _ in 0..<26 {
        context.insert(ClothingItem(imageData: Data(), category: .tops, dominantColor: .lime, matchesColorimetry: true))
    }
    for _ in 0..<4 {
        context.insert(PurchaseCheck(imageData: Data(), category: .tops, dominantColor: .lime, matchesColorimetry: true, fillsGap: nil, verdictText: "x", decision: .comprou))
    }

    let viewModel = ProfileViewModel(modelContext: context)
    return ProfileView(viewModel: viewModel, modelContext: context)
        .modelContainer(container)
}

#Preview("Profile") {
    makeProfilePreview()
}
