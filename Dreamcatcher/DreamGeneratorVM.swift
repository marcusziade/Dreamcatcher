import UIKit

enum DreamGeneratorState {
    case idle
    case loading
    case tagsLoaded([String])
    case imageLoaded(Int, UIImage)
    case error(Error)
    case completed
}

class DreamGeneratorVM {
    private(set) var tags: [String] = []
    private(set) var images: [UIImage?] = [nil, nil, nil, nil]
    private let networkService: NetworkServiceProtocol

    private let stateSubject = AsyncStream<DreamGeneratorState>.makeStream()
    var stateStream: AsyncStream<DreamGeneratorState> { stateSubject.stream }

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func generateImagesAndTags() async {
        stateSubject.continuation.yield(.loading)
        tags.removeAll()
        images = [nil, nil, nil, nil]

        let defaultPrompt = "i dreamt i was on antarctica and i saw flowers growing"

        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.generateTags(prompt: defaultPrompt) }
            group.addTask { await self.generateImages(prompt: defaultPrompt) }
        }

        stateSubject.continuation.yield(.completed)
    }

    private func generateTags(prompt: String) async {
        do {
            let newTags = try await networkService.generateTags(prompt: prompt)
            tags = newTags
            stateSubject.continuation.yield(.tagsLoaded(newTags))
        } catch {
            stateSubject.continuation.yield(.error(error))
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

            for await (index, image) in group {
                if let image = image {
                    images[index] = image
                    stateSubject.continuation.yield(.imageLoaded(index, image))
                }
            }
        }
    }
}
