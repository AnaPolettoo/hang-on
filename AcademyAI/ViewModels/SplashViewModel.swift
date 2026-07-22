import Foundation
import Observation

@MainActor
@Observable
final class SplashViewModel {
    var isReadyToAdvance = false

    func startTimer() {
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            isReadyToAdvance = true
        }
    }
}
