import ComposableArchitecture
@testable import Space2
import XCTest

@MainActor
final class SpaceTests: XCTestCase {
    func testMarvelFetch() async {
        let store = TestStore(initialState: GridFeature.State(endPoint: .characters)) {
            GridFeature()
        } withDependencies: {
            $0.marvelClient.fetch = { _, offset in
                let data = PaginatedInfo(offset: 0, limit: 20, total: 100, count: 11, results: [Character.mock.first!])
                return MarvelResponse(code: 0, status: "200", data: data)
            }
        }

        await store.send(.onTask).finish()
        store.exhaustivity = .off
        let data = PaginatedInfo(offset: 0, limit: 20, total: 100, count: 11, results: [Character.mock.first!])
        await store.receive(.marvelResponse(MarvelResponse(code: 0, status: "200", data: data))) { state in
            state.total = 100
            state.offset = 11
        }
    }
}
