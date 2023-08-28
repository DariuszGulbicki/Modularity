import Foundation
import PythonKit

/// Class for quick loading and effective management of Python modules.
public class PyModuleManager {

    /// The schema to use for validation.
    private let schema: PyModuleSchema

    /// Creates a new PyModuleManager for the given schema.
    /// Can be supplied with empty schema to disable schema validation.
    /// - Parameter schema: The schema to use for schema validation.
    /// - Returns: The created PyModuleManager.
    public static subscript(schema: PyModuleSchema) -> PyModuleManager {
        return PyModuleManager(schema)
    }

    /// Creates a new PyModuleManager for the given schema.
    /// Can be supplied with empty schema to disable schema validation.
    /// - Parameter schema: The schema to use for schema validation.
    /// - Returns: The created PyModuleManager.
    private init(_ schema: PyModuleSchema) {
        self.schema = schema
    }

    /// Returns all modules that match the given filter.
    /// Allows to quickly get modules that match a certain criteria.
    /// - Parameter filter: The filter to use.
    /// - Returns: The modules that match the filter.
    public subscript(filter: (PyModule) -> Bool) -> [PyModule] {
        return getModule(filter)
    }

    /// Executes the given function for all modules.
    /// Allows to easily execute a function for all modules.
    /// - Parameter function: The function to execute.
    public subscript(function: (PyModule) -> Void) -> Void {
        execute(function)
    }

    /// Executes the given function for all modules that match the given filter.
    /// Allows to easily execute a function for specific groups of modules.
    /// - Parameter filter: The filter to use.
    /// - Parameter function: The function to execute.
    public subscript(filter: (PyModule) -> Bool, function: (PyModule) -> Void) -> Void {
        for module in modules {
            if filter(module) {
                function(module)
            }
        }
    }

    /// Array containing all registered modules.
    private var modules: [PyModule] = []

    /// Adds the given module to the manager.
    /// - Parameter module: The module to add.
    public func register(_ module: PyModule) {
        modules.append(module)
    }

    /// Adds multiple given modules to the manager.
    /// - Parameter modules: The modules to add.
    public func register(_ modules: [PyModule]) {
        self.modules.append(contentsOf: modules)
    }

    /// Removes the given module from the manager.
    /// - Parameter module: The module to remove.
    public func unregister(_ module: PyModule) {
        modules.removeAll { $0 === module }
    }

    /// Returns all modules that match the given filter.
    /// - Parameter filter: The filter to use.
    /// - Returns: The modules that match the filter.
    public func getModule(_ filter: (PyModule) -> Bool) -> [PyModule] {
        return modules.filter(filter)
    }

    /// Executes the given function for all modules.
    /// - Parameter function: The function to execute.
    public func execute(_ function: (PyModule) -> Void) {
        for module in modules {
            function(module)
        }
    }

    /// Executes the given function for all modules.
    /// - Parameter functionName: The name of the function to execute.
    /// - Parameter parameters: The parameters to pass to the function.
    public func call(_ functionName: String, with parameters: [PythonObject] = []) {
        modules.forEach { module in
            module.dynamicallyCall(withArguments: parameters)
        }
    }

    /// Loads the given code as a module.
    /// Automatically registers the loaded module.
    /// - Parameter code: The code to load.
    public func loadCode(_ code: String) -> Void {
        let loaded = PyModuleLoader(schema).loadCode(code)
        register(loaded)
    }

    /// Loads the given file as a module.
    /// Automatically registers the loaded module.
    /// - Parameter path: The path to the file to load.
    public func loadFile(_ path: String) -> Void {
        let loaded = PyModuleLoader(schema).loadFile(path)
        register(loaded)
    }

    /// Loads the given file from a bundle as a module.
    /// Automatically registers the loaded module.
    /// - Parameter path: The path to the file to load.
    /// - Parameter bundle: The bundle to load the file from. Use `Bundle.module` for loading from the current project.
    public func loadRelativeFile(_ path: String, _ bundle: Bundle) -> Void {
        let loaded = PyModuleLoader(schema).loadRelativeFile(path, bundle)
        register(loaded)
    }

    /// Loads all files in the given directory as modules.
    /// Does not traverse subdirectories.
    /// Automatically registers the loaded modules.
    /// - Parameter path: The path to the directory to load.
    public func loadDirectory(_ path: String) -> Void {
        let loaded = PyModuleLoader(schema).loadDirectory(path)
        register(loaded)
    }

    /// Loads all files in the given directory from a bundle as modules.
    /// Does not traverse subdirectories.
    /// Automatically registers the loaded modules.
    /// - Parameter path: The path to the directory to load.
    /// - Parameter bundle: The bundle to load the files from. Use `Bundle.module` for loading from the current project.
    public func loadRelativeDirectory(_ path: String, _ bundle: Bundle) -> Void {
        let loaded = PyModuleLoader(schema).loadRelativeDirectory(path, bundle)
        register(loaded)
    }

}