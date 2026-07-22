import SwiftUI
import SwiftData

private enum OnboardingStep {
    case splash, name, findYourColors, paletteResult, catalogPrompt
}

struct OnboardingCoordinatorView: View {
    let onCompleted: () -> Void

    @State private var step: OnboardingStep = .splash
    @State private var nameViewModel = NameViewModel()
    @State private var findYourColorsViewModel: FindYourColorsViewModel
    @State private var closetViewModel: ClosetViewModel

    init(modelContext: ModelContext, onCompleted: @escaping () -> Void) {
        self.onCompleted = onCompleted
        _findYourColorsViewModel = State(initialValue: FindYourColorsViewModel(modelContext: modelContext))
        _closetViewModel = State(initialValue: ClosetViewModel(modelContext: modelContext))
    }

    var body: some View {
        Group {
            switch step {
            case .splash:
                SplashView(onFinished: { step = .name })
            case .name:
                NameView(
                    viewModel: nameViewModel,
                    onContinue: { step = .findYourColors },
                    onSkip: { step = .findYourColors }
                )
            case .findYourColors:
                FindYourColorsView(
                    viewModel: findYourColorsViewModel,
                    name: nameViewModel.name.isEmpty ? nil : nameViewModel.name,
                    onResult: { step = .paletteResult }
                )
            case .paletteResult:
                if let result = findYourColorsViewModel.result {
                    PaletteResultView(
                        viewModel: PaletteResultViewModel(
                            season: result.season,
                            recommended: result.recommended,
                            avoid: result.avoid,
                            explanation: result.explanation
                        ),
                        onStartChecking: { step = .catalogPrompt }
                    )
                }
            case .catalogPrompt:
                CatalogPromptView(viewModel: closetViewModel, onContinue: onCompleted)
            }
        }
    }
}
