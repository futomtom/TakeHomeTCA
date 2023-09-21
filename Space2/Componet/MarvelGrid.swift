import ComposableArchitecture
import SwiftUI

typealias MarvelResponse = Response<PaginatedInfo<Character>>

struct GridFeature: Reducer {
    struct State: Equatable {
        let endPoint: Marvel.EndPoint
        var offset = 0
        var total = 0
        var characters: IdentifiedArrayOf<Character> = []
        var isLoading = false

        private var hasMore: Bool = true

        init(endPoint: Marvel.EndPoint, mock: [Character] = []) {
            self.endPoint = endPoint
            characters = IdentifiedArray(uniqueElements: mock)
        }

        mutating func updateState(_ response: MarvelResponse) {
            let data = response.data

            let newCharacters = data.results ?? []
            characters.append(contentsOf: IdentifiedArray(uniqueElements: newCharacters))
            offset = data.offset + data.count
            total = data.total
            hasMore = data.count == data.limit
        }

        fileprivate func canLoadMore(_ character: Character) -> Bool {
            characters.isLast(character) && hasMore && characters.count != total
        }
    }

    enum Action: Equatable {
        case onTask
        case loadMoreIfPossible(Character)
        case marvelResponse(MarvelResponse)
    }

    @Dependency(\.marvelClient) var marvelClient
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onTask:
                return .run { [endPoint = state.endPoint, offset = state.offset] send in
                    try await send(.marvelResponse(marvelClient.fetch(endPoint, offset)))
                }

            case let .marvelResponse(response):
                state.updateState(response)
                return .none

            case let .loadMoreIfPossible(character):
                guard state.canLoadMore(character) else {
                    return .none
                }
                return .run { [endPoint = state.endPoint, offset = state.offset] send in
                    try await send(
                        .marvelResponse(marvelClient.fetch(endPoint, offset))
                    )
                }
            }
        }
    }
}

struct MarvelGrid: View {
    let store: StoreOf<GridFeature>
    let titleShown: Bool
    let tappable: Bool

    init(store: StoreOf<GridFeature>, titleShown: Bool = true, tappable: Bool = true) {
        self.store = store
        self.titleShown = titleShown
        self.tappable = tappable
    }

    var columns: [GridItem] =
        Array(repeating: .init(.flexible(), spacing: Constant.gridSpacing), count: 3)

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ScrollView(.vertical) {
                LazyVGrid(columns: columns, spacing: Constant.gridSpacing) {
                    ForEach(viewStore.characters) { character in
                        NavigationLink(
                            state: AppFeature.Path.State.detail(DetailFeature.State(character: character))
                        ) {
                            GridCell(character: character)
                        }
                        .disabled(!tappable)
                        .onAppear() {
                            if viewStore.characters.isLast(character) {
                                viewStore.send(.loadMoreIfPossible(character))
                            }
                        }
                    }
                }
            }
            .onFirstAppear {
                Task {
                    await viewStore.send(.onTask).finish()
                }
            }
        }
    }
}

struct CharactersGrid_Previews: PreviewProvider {
    static var previews: some View {
        MarvelGrid(
            store: Store(initialState: .init(endPoint: .characters, mock: Character.mock)) {
                GridFeature()
            },
            titleShown: true,
            tappable: true
        )
    }
}
