import Foundation

protocol Cancellable {
    func cancel()
}

class TaskCancellable: Cancellable {
    private let task: Task<Void, Never>
    
    init(task: Task<Void, Never>) {
        self.task = task
    }
    
    func cancel() {
        task.cancel()
    }
}
