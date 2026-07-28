import SwiftUI
import UIKit

struct PurchaseCheckView: View {
    let viewModel: PurchaseCheckViewModel

    private let horizontalPadding: CGFloat = 16

    @State private var showCamera = false
    @State private var showLibrary = false
    @State private var pendingLibraryImage: UIImage?
    @State private var pendingVerdict: PendingVerdict?

    struct PendingVerdict: Identifiable, Hashable {
        let id = UUID()
        let displayImage: UIImage
        let imageData: Data
        let category: ClothingCategory
        let dominantColor: ClosetColor
        let matchesColorimetry: Bool?
        let fillsGap: Bool?
        let similarItems: [UIImage]
        let similarItemsTotalCount: Int
        let motivo: String
        let recomendacao: String

        // `.navigationDestination(item:)` requires Hashable, not just Identifiable.
        // Equality/hash by `id` alone — the struct's own UUID already uniquely
        // identifies a given verdict, and several fields (UIImage) aren't Hashable.
        static func == (lhs: PendingVerdict, rhs: PendingVerdict) -> Bool { lhs.id == rhs.id }
        func hash(into hasher: inout Hasher) { hasher.combine(id) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ctaCard
                statsRow
                if viewModel.recentChecks.isEmpty {
                    emptyChecksCard
                } else {
                    recentChecksSection
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(Theme.Font.caption)
                        .foregroundStyle(Theme.Color.inkMuted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, horizontalPadding)
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Color.cream.ignoresSafeArea())
        .navigationTitle("Hi, \(viewModel.profileName ?? "there")")
        .navigationBarTitleDisplayMode(.large)
        .fullScreenCover(isPresented: $showCamera) {
            CameraCaptureView(
                cameraDevice: .rear,
                onCapture: { image in
                    showCamera = false
                    Task { await process(image) }
                },
                onCancel: { showCamera = false }
            )
            .ignoresSafeArea()
        }
        .sheet(isPresented: $showLibrary) {
            PhotoLibraryPickerView(
                onPick: { image in
                    showLibrary = false
                    pendingLibraryImage = uprightImage(from: image)
                },
                onCancel: { showLibrary = false }
            )
        }
        .fullScreenCover(isPresented: Binding(
            get: { pendingLibraryImage != nil },
            set: { isPresented in if !isPresented { pendingLibraryImage = nil } }
        )) {
            if let pendingLibraryImage {
                processingView
                    .task {
                        await process(pendingLibraryImage)
                        self.pendingLibraryImage = nil
                    }
            }
        }
        .navigationDestination(item: $pendingVerdict) { verdict in
            PurchaseCheckVerdictView(
                displayImage: verdict.displayImage,
                itemTitle: "\(ClothingColorSwatch.nearest(to: verdict.dominantColor).displayName) \(verdict.category.displayNoun)",
                colorSwatch: ClothingColorSwatch.nearest(to: verdict.dominantColor),
                category: verdict.category,
                matchesColorimetry: verdict.matchesColorimetry,
                fillsGap: verdict.fillsGap,
                similarItemImages: verdict.similarItems,
                similarItemsTotalCount: verdict.similarItemsTotalCount,
                motivo: verdict.motivo,
                recomendacao: verdict.recomendacao,
                onPass: { recordDecision(.naoComprou, verdict: verdict) },
                onBuy: { recordDecision(.comprou, verdict: verdict) }
            )
        }
        .onChange(of: viewModel.pendingAutoLaunchCamera) { _, shouldLaunch in
            guard shouldLaunch else { return }
            showCamera = true
            viewModel.pendingAutoLaunchCamera = false
        }
        .onAppear {
            viewModel.loadHistory()
            guard viewModel.pendingAutoLaunchCamera else { return }
            showCamera = true
            viewModel.pendingAutoLaunchCamera = false
        }
    }

    // A Menu instead of a confirmationDialog so the Take Photo / Choose from Library
    // choices pop up anchored right at this button, not as an unrelated sheet sliding
    // up from the bottom of the screen. The label reproduces PrimaryButtonStyle's look
    // by hand — a custom ButtonStyle isn't guaranteed to apply to a Menu's trigger.
    private var checkAPieceMenu: some View {
        Menu {
            // The Menu's own dismissal is a UIKit context-menu animation that spans
            // several run loop turns; presenting a fullScreenCover/sheet before it
            // finishes hangs the UI (menu closes but touches stop registering).
            // A same-tick `.async` isn't a long enough delay — this needs to clear
            // the whole dismiss animation, not just the next run loop turn.
            Button { DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { showCamera = true } } label: {
                Label("Take Photo", systemImage: "camera.fill")
            }
            .tint(Theme.Color.accentBorder)
            Button { DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { showLibrary = true } } label: {
                Label("Choose from Library", systemImage: "photo.on.rectangle.fill")
            }
            .tint(Theme.Color.accentBorder)
        } label: {
            Text("Check a piece")
                .font(Theme.Font.button)
                .foregroundStyle(Theme.Color.cream)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Theme.Color.ink)
                .clipShape(Capsule())
        }
        .disabled(viewModel.isProcessing)
    }

    private var ctaCard: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .top) {
                VStack(spacing: 8) {
                    Text("Should you buy it?")
                        .font(Theme.Font.sectionTitle)
                        .foregroundStyle(Theme.Color.ink)
                    Text("Snap a piece before you buy. I'll check it against your palette and closet.")
                        .font(Theme.Font.subheadline)
                        .foregroundStyle(Theme.Color.inkMuted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                    checkAPieceMenu
                }
                .padding(.top, 48)
                .padding(.bottom, 22)
                .padding(.horizontal, 26)
                .background(Color(hex: "F6F2EA"))
                .overlay(RoundedRectangle(cornerRadius: 26).stroke(Theme.Color.ink, lineWidth: 2))
                .clipShape(RoundedRectangle(cornerRadius: 26))
                .padding(.top, 30)

                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 28))
                    .foregroundStyle(Theme.Color.ink)
                    .frame(width: 60, height: 60)
                    .background(Theme.Color.cream)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Theme.Color.ink, lineWidth: 2))
            }

            if viewModel.isProcessing {
                ProgressView().tint(Theme.Color.ink).padding(.top, 16)
            }
        }
        .padding(.horizontal, horizontalPadding)
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            Text("\(viewModel.checkedCount) checked")
            Text("·").foregroundStyle(Theme.Color.ink.opacity(0.35))
            Text("\(viewModel.boughtCount) bought")
            Text("·").foregroundStyle(Theme.Color.ink.opacity(0.35))
            Text("\(viewModel.passedCount) passed")
        }
        .font(Theme.Font.caption)
        .foregroundStyle(Theme.Color.ink.opacity(0.6))
    }

    private var emptyChecksCard: some View {
        VStack(spacing: 6) {
            Text("Nothing to hang on to yet.")
                .font(Theme.Font.body)
                .foregroundStyle(Theme.Color.ink.opacity(0.7))
            Text("Next time you're tempted, snap it first.")
                .font(Theme.Font.subheadline)
                .foregroundStyle(Theme.Color.inkMuted)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, 16)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(style: StrokeStyle(lineWidth: 2, dash: [6]))
                .foregroundStyle(Theme.Color.ink.opacity(0.3))
        )
        .padding(.horizontal, horizontalPadding)
    }

    private var recentChecksSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("RECENT CHECKS")
                .font(Theme.Font.caption)
                .foregroundStyle(Theme.Color.inkMuted)
                .tracking(0.5)
                .padding(.leading, 4)

            VStack(spacing: 0) {
                ForEach(Array(viewModel.recentChecks.enumerated()), id: \.element.id) { index, check in
                    recentCheckRow(check)
                    if index < viewModel.recentChecks.count - 1 {
                        Divider().background(Theme.Color.ink.opacity(0.1))
                    }
                }
            }
            .background(Color(hex: "F6F2EA"))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.Color.ink, lineWidth: 2))
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
        .padding(.horizontal, horizontalPadding)
    }

    private func recentCheckRow(_ check: PurchaseCheck) -> some View {
        let recommendation = PurchaseRecommendation.evaluate(matchesColorimetry: check.matchesColorimetry, fillsGap: check.fillsGap)
        let title = "\(ClothingColorSwatch.nearest(to: check.dominantColor).displayName) \(check.category.displayNoun)"

        return HStack(spacing: 12) {
            Group {
                if let uiImage = UIImage(data: check.imageData) {
                    Image(uiImage: uiImage).resizable().scaledToFill()
                } else {
                    Theme.Color.ink.opacity(0.06)
                }
            }
            .frame(width: 44, height: 64)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Theme.Font.body)
                    .foregroundStyle(Theme.Color.ink)
                Text("\(recommendation.glyphPrefix) \(recommendation.title)")
                    .font(Theme.Font.caption)
                    .foregroundStyle(Theme.Color.inkMuted)
            }

            Spacer(minLength: 0)

            Group {
                switch check.decision {
                case .comprou:
                    Text("Bought")
                        .foregroundStyle(Theme.Color.cream)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 2)
                        .background(Theme.Color.ink)
                        .clipShape(Capsule())
                case .naoComprou:
                    Text("Passed")
                        .foregroundStyle(Theme.Color.ink)
                        .padding(.horizontal, 13)
                        .padding(.vertical, 3)
                        .overlay(Capsule().stroke(Theme.Color.ink, lineWidth: 1))
                }
            }
            .font(Theme.Font.caption)
        }
        .padding(12)
    }

    private var processingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(Theme.Color.cream)
                .controlSize(.large)
            Text("Hang on, checking it against your palette and closet…")
                .font(Theme.Font.subheadline)
                .foregroundStyle(Theme.Color.cream.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Color.ink.ignoresSafeArea())
    }

    private func uprightImage(from image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        let upright = ImageOrientation.upright(cgImage, orientation: CGImagePropertyOrientation(image.imageOrientation))
        return UIImage(cgImage: upright)
    }

    private func process(_ image: UIImage) async {
        guard let cgImage = image.cgImage else {
            viewModel.errorMessage = String(localized: "Couldn't process the photo. Try again.")
            return
        }
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        guard let processed = await viewModel.checkPiece(cgImage, orientation: orientation) else { return }

        let displayImage = UIImage(cgImage: processed.image)
        guard let imageData = displayImage.pngData() else {
            viewModel.errorMessage = String(localized: "Couldn't process the photo. Try again.")
            return
        }

        pendingVerdict = PendingVerdict(
            displayImage: displayImage,
            imageData: imageData,
            category: processed.classification.category,
            dominantColor: processed.classification.dominantColor,
            matchesColorimetry: processed.matchesColorimetry,
            fillsGap: processed.fillsGap,
            similarItems: processed.similarItems.prefix(3).compactMap { UIImage(data: $0.imageData) },
            similarItemsTotalCount: processed.similarItems.count,
            motivo: processed.motivo,
            recomendacao: processed.recomendacao
        )
    }

    private func recordDecision(_ decision: PurchaseDecision, verdict: PendingVerdict) {
        viewModel.recordDecision(
            imageData: verdict.imageData,
            category: verdict.category,
            dominantColor: verdict.dominantColor,
            matchesColorimetry: verdict.matchesColorimetry,
            fillsGap: verdict.fillsGap,
            verdictText: "\(verdict.motivo)\n\n\(verdict.recomendacao)",
            decision: decision
        )
        pendingVerdict = nil
    }
}
