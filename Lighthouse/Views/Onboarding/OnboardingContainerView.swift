import SwiftUI
import SwiftData

struct OnboardingContainerView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var viewModel: OnboardingViewModel
    var onComplete: () -> Void

    var body: some View {
        ZStack {
            LHColor.background.ignoresSafeArea()

            switch viewModel.currentStep {
            case .splash:
                SplashView(viewModel: viewModel)
            case .name:
                NameInputView(viewModel: viewModel)
            case .habits:
                HabitsQuizView(viewModel: viewModel)
            case .apps:
                AppSelectionView(viewModel: viewModel)
            case .commitment:
                CommitmentView(viewModel: viewModel)
            case .loading:
                LoadingPlanView(viewModel: viewModel)
            case .paywall:
                PaywallView(viewModel: viewModel) {
                    let _ = viewModel.createProfile(modelContext: modelContext)
                    onComplete()
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
