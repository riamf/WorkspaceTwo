import Foundation

public typealias DispatchFunction = (Action) -> Void
public typealias Middleware<State> = (@escaping DispatchFunction, @escaping () -> StateStore?)
                                -> (@escaping DispatchFunction) -> DispatchFunction
public typealias Reducer<ReducerStateType> = (_ action: Action, _ state: ReducerStateType?) -> ReducerStateType

public class ReduxStore {
    var state: StateStore? {
        didSet {
            guard let state = state else { return }
            subscribers.allObjects.forEach {
                ($0 as? StateChangeObserver)?.notify(state, oldState: oldValue)
            }
        }
    }
    var subscribers = NSPointerArray(options: .weakMemory)
    var middleware: [Middleware<StateStore>]
    var reducer: Reducer<StateStore>
    var dispatchFunction: DispatchFunction!

    public init(state: StateStore?,
         reducer: @escaping Reducer<StateStore>,
         middleware: [Middleware<StateStore>] = []) {
        self.reducer = reducer
        self.middleware = middleware
        self.dispatchFunction = middleware.reversed().reduce(
            { [unowned self] action in self._defaultDispatch(action: action) },
            { dispatchFunction, middleware in
            let dispatch: (Action) -> Void = { [weak self] in self?.dispatch($0) }
            let getState = { [weak self] in self?.state }
            return middleware(dispatch, getState)(dispatchFunction)
        })
        
        if let state = state {
            self.state = state
        }
    }
    
    public func dispatch(_ action: Action) {
        dispatchFunction(action)
    }
    
    public func add(subscriber: StateChangeObserver) {
        subscribers
            .addPointer(Unmanaged.passUnretained(subscriber as AnyObject).toOpaque())
    }
    
    func _defaultDispatch(action: Action) {
        let newState = reducer(action, state)
        state = newState
    }
}

