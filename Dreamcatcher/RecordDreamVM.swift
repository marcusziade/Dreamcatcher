import Combine
import UIKit

final class RecordDreamVM {

    enum State {
        case idle, editing, readyToSubmit, analyzing, result, error

        var editButtonTitle: String {
            switch self {
            case .idle: "Record your dream"
            case .readyToSubmit: "Edit dream"
            case .analyzing: "Analyzing dream"
            default: " "
            }
        }
    }

    let dreamText = CurrentValueSubject<String, Never>("")
    let state = CurrentValueSubject<State, Never>(.idle)

    let onSubmitTapped = PassthroughSubject<Void, Never>()
    let onEditButtonTapped = PassthroughSubject<Void, Never>()
    let onDoneEditing = PassthroughSubject<Void, Never>()

    let settings: Settings

    init(settings: Settings) {
        self.settings = settings

        setupBindings()
    }

    // MARK: Private

    private var cancellables = Set<AnyCancellable>()

    private func setupBindings() {
        onDoneEditing.sink { [unowned self] _ in
            if dreamText.value.isEmpty {
                state.send(.idle)
            } else {
                state.send(.readyToSubmit)
            }
        }
        .store(in: &cancellables)

        onSubmitTapped.sink { [unowned self] _ in
            state.send(.analyzing)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
                state.send(Bool.random() ? .result : .error)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
                    clearText()
                    state.send(.idle)
                }
            }
        }
        .store(in: &cancellables)

        onEditButtonTapped.sink { [unowned self] _ in
            state.send(.editing)
        }
        .store(in: &cancellables)
    }

    func clearText() {
        dreamText.send("")
    }
}
