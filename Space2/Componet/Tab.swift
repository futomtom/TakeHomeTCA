import ComposableArchitecture
import SwiftUI

enum TabMode: CaseIterable, Equatable {
    case comics
    case events

    var isComics: Bool {
        self == .comics
    }
}

struct TabFeature: Reducer {
    struct State: Equatable {
        var mode: TabMode = .comics
    }

    enum Action: Equatable {
        case tabTapped(TabMode)
        case delegate(Delegate)
        enum Delegate: Equatable {
            case tabSwitch(mode: TabMode)
        }
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .tabTapped(mode):
                state.mode = mode
                return .none
            case .delegate:
                return .none
            }
        }
    }
}

struct Tab: View {
    let store: StoreOf<TabFeature>
    let character: Character

    @Namespace private var animation

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            HStack(spacing: 30) {
                ForEach(TabMode.allCases, id: \.self) { tab in
                    VStack {
                        tabIcon(tab: tab, mode: viewStore.mode)
                        Text(character.getTitle(for: tab))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 5)
                    }
                    .padding()
                    .background {
                        if viewStore.mode == tab {
                            Rectangle()
                                .fill(.blue)
                                .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
                        } else {
                            Rectangle()
                                .fill(.gray.opacity(0.1))
                        }
                    }
                    .foregroundColor(viewStore.mode == tab ? .white : .secondary)

                    .onTapGesture {
                        viewStore.send(.tabTapped(tab), animation: .default)
                    }
                }
            }
        }
    }

    func tabIcon(tab: TabMode, mode: TabMode) -> some View {
        var iconName = ""
        if tab == .comics {
            iconName = tab == mode ? "book.fill" : "book"
        } else {
            iconName = tab == mode ? "tv.fill" : "tv"
        }
        return Image(systemName: iconName)
    }
}

struct Tab_Previews: PreviewProvider {
    static var previews: some View {
        Tab(
            store: Store(initialState: TabFeature.State()) {
                TabFeature()
            }, character: Character.mock.first!
        )
    }
}
