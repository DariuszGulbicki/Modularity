/// Error thrown when a module fails to load.
public class ModuleLoadingError<T: Module>: Error {
    
    /// The error message.
    /// Should contain short information about what went wrong during loading.
    public let message: String
    
    /// The type of the module that failed to load.
    /// Used for type checking and debugging.
    public var moduleType: T.Type {
        return T.self
    }

    /// The error description.
    /// Should be descriptive.
    public var description: String {
        return message
    }

    /// Creates a new module loading error with the given message.
    /// - Parameter message: The error message.
    public init(_ message: String) {
        self.message = message
    }
    
}