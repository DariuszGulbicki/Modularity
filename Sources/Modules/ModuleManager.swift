/// A class that allows for quick loading and effective management of modules.
public class ModuleManager<T: Module> {

    /// Creates a new module manager for the given module type.
    /// Type T represents the module type.
    /// - Parameter module: The module type. Use `CustomModule.self` format.
    /// - Returns: The created module manager.
    public static subscript(module: T.Type) -> ModuleManager<T> {
        return ModuleManager<T>()
    }

    /// Creates a new module manager for the given module type.
    private init() {

    }

    /// Returns all modules that match the given filter.
    /// Allows to quickly get modules that match a certain criteria.
    /// - Parameter filter: The filter to use.
    /// - Returns: The modules that match the filter.
    public subscript(filter: (T) -> Bool) -> [T] {
        return getModule(filter)
    }

    /// Executes the given function for all modules.
    /// Allows to easily execute a function for all modules.
    /// - Parameter function: The function to execute.
    public subscript(function: (T) -> Void) -> Void {
        execute(function)
    }

    /// Executes the given function for all modules that match the given filter.
    /// Allows to easily execute a function for specific groups of modules.
    /// - Parameter filter: The filter to use.
    /// - Parameter function: The function to execute.
    public subscript(filter: (T) -> Bool, function: (T) -> Void) -> Void {
        for module in modules {
            if filter(module) {
                function(module)
            }
        }
    }

    /// Array containing all registered modules.
    private var modules: [T] = []

    /// Adds the given module to the manager.
    /// - Parameter module: The module to add.
    public func register(_ module: T) {
        modules.append(module)
    }

    /// Adds multiple given modules to the manager.
    /// - Parameter modules: The modules to add.
    public func register(_ modules: [T]) {
        self.modules.append(contentsOf: modules)
    }

    /// Removes the given module from the manager.
    /// - Parameter module: The module to remove.
    public func unregister(_ module: T) {
        modules.removeAll { $0 === module }
    }

    /// Returns all modules that match the given filter.
    /// - Parameter filter: The filter to use.
    /// - Returns: The modules that match the filter.
    public func getModule(_ filter: (T) -> Bool) -> [T] {
        return modules.filter(filter)
    }

    /// Executes the given function for all modules.
    /// - Parameter function: The function to execute.
    public func execute(_ function: (T) -> Void) {
        for module in modules {
            function(module)
        }
    }

    /// Calls a function stored in a let constant in all modules.
    /// Uses reflection to find the function.
    /// Slow, but allows for easy function calling. Should only be used for functions that are called rarely.
    /// 
    /// `This method has been marked as deprecated because of its poor performance. However, there are no plans to remove it.
    /// You can still use it for testing and rarely called functions if you want to.`
    /// - Parameter functionName: The name of the function to call.
    /// - Parameter parameters: The parameters to pass to the function.
    /// - Returns: An array containing all return values.
    @available(*, deprecated, message: "This method is inefficient and should not be used. Use the subscript instead.")
    public func callLetFunction(_ functionName: String, with parameters: [Any]) {
        for module in modules {
            let mirror = Mirror(reflecting: module)
            for child in mirror.children {
                if let function = child.value as? (([Any]) -> Void), child.label == functionName {
                    function(parameters)
                }
            }
        }
    }

    /// Returns all values stored in a let constant in all modules.
    /// Uses reflection to find the values.
    /// Slow, but allows for easy value retrieval. Should only be used for values that are retrieved rarely.
    /// 
    /// `This method has been marked as deprecated because of its poor performance. However, there are no plans to remove it.
    /// You can still use it for testing and rarely called functions if you want to.`
    /// - Parameter valueName: The name of the value to retrieve.
    /// - Returns: An array containing all values.
    @available(*, deprecated, message: "This method is inefficient and should not be used. Use the subscript instead.")
    public func getLetValues<T>(_ valueName: String) -> [T] {
        var values: [T] = []
        for module in modules {
            let mirror = Mirror(reflecting: module)
            for child in mirror.children {
                if let value = child.value as? T, child.label == valueName {
                    values.append(value)
                }
            }
        }
        return values
    }

    /// Loads the given module from class name.
    /// - Parameter className: The name of the class to load. Must be a subclass of `T`. Use `CustomModule.self` format.
    public func load(_ className: String) throws -> Void {
        let loaded = try! ModuleLoader[T.self].load(className: className)
        register(loaded)
    }

    /// Loads the given modules from class names.
    /// - Parameter classNames: The names of the classes to load. Must be a subclass of `T`. Use `CustomModule.self` format.
    public func load(_ classNames: String...) throws -> Void {
        let loaded = try! ModuleLoader[T.self].loadMultiple(classNames: classNames)
        register(loaded)
    }

    /// Loads all modules from the given directory.
    /// 
    /// `This method has been marked as deprecated due to its misleading name. It does not load modules from .swift files.
    /// It loads modules from .d files. Dynamic loading of .swift files is impossible.
    /// There are no plans to remove this method for compatibility reasons.`
    /// - Parameter directory: The directory to load from.
    /// - Parameter package: The package to load from. Defaults to `nil`.
    @available(*, deprecated, message: "Misleading and works only in very specific cases. Dynamic loading of .swift files is impossible. There are no plans to remove this method.")
    public func loadFromDirectory(_ directory: String, _ package: String? = nil) -> Void {
        let loaded = ModuleLoader[T.self].loadFromDirectory(directory, package)
        register(loaded)
    }

}