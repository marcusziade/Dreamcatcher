import Combine
import UIKit

final class RecordDreamVM {

    let dreamText = CurrentValueSubject<String, Never>("")
    let isTextViewVisible = CurrentValueSubject<Bool, Never>(false)
    let saveDreamTrigger = PassthroughSubject<Void, Never>()

    let settings: Settings

    private var cancellables = Set<AnyCancellable>()

    init(settings: Settings) {
        self.settings = settings

        setupBindings()
    }

    private func setupBindings() {
        dreamText
            .dropFirst()
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { [unowned self] _ in
                saveDreamTrigger.send()
            }
            .store(in: &cancellables)

        saveDreamTrigger
            .sink { [unowned self] in
                saveDream()
            }
            .store(in: &cancellables)
    }

    func showTextView() {
        isTextViewVisible.send(true)
    }

    func hideTextView() {
        isTextViewVisible.send(false)
    }

    func clearText() {
        dreamText.send("")
    }

    private func saveDream() {
        // Implement dream saving logic here
        print("Saving dream: \(dreamText.value)")
    }
}
