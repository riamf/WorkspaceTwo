import Foundation

public protocol State {
    func reduce(_ action: Action) -> State
}

public struct StateStore {
    private(set) var store: [State]
    public init(store: [State]) {
        self.store = store
    }
    
    public func getStore() -> [State] {
        return store
    }
}

public protocol StateChangeObserver {
    func notify(_ state: StateStore, oldState: StateStore?)
}

public protocol Action {
    
}
