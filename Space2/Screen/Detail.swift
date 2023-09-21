import ComposableArchitecture
import SwiftUI

struct DetailFeature: Reducer {
    struct State: Equatable {
        var character: Character
        var tab = TabFeature.State()
        var comics: GridFeature.State
        var events: GridFeature.State

        init(character: Character, mock: [Character] = []) {
            self.character = character
            comics = GridFeature.State(endPoint: .comics(character.Id), mock: mock)
            events = GridFeature.State(endPoint: .events(character.Id), mock: mock)
        }
    }

    enum Action: Equatable {
        case tab(TabFeature.Action)
        case comics(GridFeature.Action)
        case events(GridFeature.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.tab, action: /Action.tab) {
            TabFeature()
        }

        Scope(state: \.comics, action: /Action.comics) {
            GridFeature()
        }

        Scope(state: \.events, action: /Action.events) {
            GridFeature()
        }

        Reduce { _, action in
            switch action {
            case .tab:
                return .none

            case .comics:
                return .none

            case .events:
                return .none
            }
        }
    }
}

struct Detail: View {
    let store: StoreOf<DetailFeature>

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                Panel(content: Header(character: viewStore.character))
                Tab(
                    store: self.store.scope(state: \.tab,
                                            action: DetailFeature.Action.tab),
                    character: viewStore.character
                )
                
                if viewStore.tab.mode.isComics {
                    MarvelGrid(
                        store: self.store.scope(state: \.comics, action: { .comics($0) }),
                        titleShown: false,
                        tappable: false
                    )
                } else {
                    MarvelGrid(
                        store: self.store.scope(state: \.events, action: { .events($0) }),
                        titleShown: false,
                        tappable: false
                    )
                }
            }
            .toolbar {
                Image(systemName: "ellipsis")
            }
        }
    }
}

struct Detail_Previews: PreviewProvider {
    static var previews: some View {
        let character = Character.mock.first!
        Detail(
            store: Store(initialState: DetailFeature.State(character: character, mock: Character.mock)) {
                DetailFeature()
            })
    }
}
