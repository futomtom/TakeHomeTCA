import ComposableArchitecture
import Foundation
import SwiftUI

extension IdentifiedArray where Element == Character {
    func isLast(_ character: Character) -> Bool {
        endIndex - 1 == lastIndex(of: character)
    }
}

public extension View {
    func onFirstAppear(_ action: @escaping () -> Void) -> some View {
        modifier(FirstAppear(action: action))
    }
}

private struct FirstAppear: ViewModifier {
    let action: () -> Void

    // Use this to only fire your block one time
    @State private var hasAppeared = false

    func body(content: Content) -> some View {
        // And then, track it here
        content.onAppear {
            guard !hasAppeared else { return }
            hasAppeared = true
            action()
        }
    }
}
