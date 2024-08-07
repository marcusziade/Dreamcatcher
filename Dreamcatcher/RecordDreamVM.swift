import Combine
import UIKit

final class RecordDreamVM {

    enum State: Equatable {
        case idle, editing, readyToSubmit, analyzing, result, error(Error)

        var editButtonTitle: String {
            switch self {
            case .idle: "Record your dream"
            case .readyToSubmit: "Edit dream"
            case .analyzing: "Analyzing dream"
            default: " "
            }
        }

        static func == (lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.editing, .editing), (.readyToSubmit, .readyToSubmit),
                (.analyzing, .analyzing), (.result, .result):
                return true
            case let (.error(lhsError), .error(rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            default:
                return false
            }
        }
    }

    let dreamText = CurrentValueSubject<String, Never>("")
    let state = CurrentValueSubject<State, Never>(.idle)
    var tags = CurrentValueSubject<[String], Never>([])
    var images = CurrentValueSubject<[UIImage], Never>([])

    let onSubmitTapped = PassthroughSubject<Void, Never>()
    let onEditButtonTapped = PassthroughSubject<Void, Never>()
    let onDoneEditing = PassthroughSubject<Void, Never>()

    let settings: Settings

    init(networkService: NetworkServiceProtocol, settings: Settings) {
        self.networkService = networkService
        self.settings = settings

        setupBindings()
    }

    // MARK: Private

    private var cancellables = Set<AnyCancellable>()
    private let networkService: NetworkServiceProtocol

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
            Task {
                await generateImagesAndTags()
            }
        }
        .store(in: &cancellables)

        onEditButtonTapped.sink { [unowned self] _ in
            state.send(.editing)
        }
        .store(in: &cancellables)
    }

    private func generateImagesAndTags() async {
        state.send(.analyzing)
        tags.send([])
        images.send([])

        await withTaskGroup(of: Void.self) { group in
            group.addTask { [unowned self] in await self.generateTags(prompt: dreamText.value) }
            group.addTask { [unowned self] in await self.generateImages(prompt: dreamText.value) }
        }

        state.send(.result)
    }

    private func generateTags(prompt: String) async {
        do {
            let newTags = try await networkService.generateTags(prompt: prompt)
            tags.send(newTags)
        } catch {
            state.send(.error(error))
        }
    }

    private func generateImages(prompt: String) async {
        await withTaskGroup(of: (Int, UIImage?).self) { group in
            for index in 0..<4 {
                group.addTask {
                    do {
                        let image = try await self.networkService.generateDreamImage(prompt: prompt)
                        return (index, image)
                    } catch {
                        print("Error generating image \(index): \(error)")
                        return (index, nil)
                    }
                }
            }
            
            var newImages = [UIImage?](repeating: nil, count: 4)
            for await (index, image) in group {
                guard let image else { continue }
                newImages[index] = image
            }
            images.send(newImages.compactMap { $0 })
        }
    }

    func clearText() {
        dreamText.send("")
    }
}
