public class ModuleLoadingError<T: Module>: Error {
    
    public let message: String
    
    public var moduleType: T.Type {
        return T.self
    }

    public var description: String {
        return message
    }

    public init(_ message: String) {
        self.message = message
    }
    
}