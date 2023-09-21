import ComposableArchitecture
import SwiftUI

struct AppFeature: Reducer {
    struct State: Equatable {
        var path = StackState<Path.State>()
        var gridState = GridFeature.State(endPoint: .characters)
    }

    enum Action: Equatable {
        case path(StackAction<Path.State, Path.Action>)
        case charactersGrid(GridFeature.Action)
    }

    struct Path: Reducer {
        enum State: Equatable {
            case detail(DetailFeature.State)
        }

        enum Action: Equatable {
            case detail(DetailFeature.Action)
        }

        var body: some ReducerOf<Self> {
            Scope(state: /State.detail, action: /Action.detail) {
                DetailFeature()
            }
        }
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.gridState, action: /Action.charactersGrid) {
            GridFeature()
        }

        Reduce { _, action in
            switch action {
            case .path:
                return .none

            case .charactersGrid:
                return .none
            }
        }
        .forEach(\.path, action: /Action.path) {
            Path()
        }
    }
}

struct AppView: View {
    let store: StoreOf<AppFeature>

    var body: some View {
        NavigationStackStore(
            self.store.scope(state: \.path, action: { .path($0) })
        ) {
            MarvelGrid(
                store: self.store.scope(
                    state: \.gridState,
                    action: { .charactersGrid($0) }
                )
            )
            .toolbar(content: {
                Text(" ")
            })
            .navigationTitle("")
        } destination: { state in
            switch state {
            case .detail:
                CaseLet(
                    /AppFeature.Path.State.detail,
                    action: AppFeature.Path.Action.detail,
                    then: Detail.init(store:)
                )
            }
        }
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(
            store: Store(
                initialState: AppFeature.State(gridState: .init(endPoint: .characters))) {
                    AppFeature()
                }
        )
    }
}
