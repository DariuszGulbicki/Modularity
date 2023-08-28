import Foundation
import JXKit

/// Class for quick loading and effective management of JavaScript modules.
/// Automatically tests modules against a schema.
/// Use JSModuleSchema() for an empty schema that accepts all modules.
public class JSModuleManager {

    /// The schema to test modules against.
    private let schema: JSModuleSchema

    /// Creates a new module manager with the given schema.
    /// - Parameter schema: The schema to test modules against.
    /// - Returns: The created module manager.
    public static subscript(schema: JSModuleSchema) -> JSModuleManager {
        return JSModuleManager(schema)
    }

    /// Creates a new module manager with the given schema.
    private init(_ schema: JSModuleSchema) {
        self.schema = schema
    }

    /// Returns all modules that matche the given filter.
    /// Can be used to quickly sort through modules.
    /// - Parameter filter: The filter to match modules against.
    /// - Returns: The modules that match the filter.
    public subscript(filter: (JSModule) -> Bool) -> [JSModule] {
        return getModule(filter)
    }

    /// Executes the given function on all modules.
    /// Can be used to quickly execute code on all modules.
    /// - Parameter function: The function to execute.
    public subscript(function: (JSModule) -> Void) -> Void {
        execute(function)
    }

    /// Executes the given function on all modules that matche the given filter.
    /// Can be used to quickly execute code on a specific module.
    /// - Parameter filter: The filter to match modules against.
    /// - Parameter function: The function to execute.
    public subscript(filter: (JSModule) -> Bool, function: (JSModule) -> Void) -> Void {
        for module in modules {
            if filter(module) {
                function(module)
            }
        }
    }

    /// All modules that have been registered.
    private var modules: [JSModule] = []

    /// Adds a module to the manager.
    /// - Parameter module: The module to add.
    public func register(_ module: JSModule) {
        modules.append(module)
    }

    /// Adds multiple modules to the manager.
    /// - Parameter modules: The modules to add.
    public func register(_ modules: [JSModule]) {
        self.modules.append(contentsOf: modules)
    }

    /// Removes a module from the manager.
    /// - Parameter module: The module to remove.
    public func unregister(_ module: JSModule) {
        modules.removeAll { $0 === module }
    }

    /// Returns the first module that matches the given filter.
    /// - Parameter filter: The filter to match modules against.
    /// - Returns: The first module that matches the filter.
    public func getModule(_ filter: (JSModule) -> Bool) -> [JSModule] {
        return modules.filter(filter)
    }

    /// Executes the given function on all modules.
    /// - Parameter function: The function to execute.
    public func execute(_ function: (JSModule) -> Void) {
        for module in modules {
            function(module)
        }
    }

    /// Executes the given function on all modules.
    /// - Parameter functionName: The function to execute.
    /// - Parameter parameters: The parameters to pass to the function.
    public func call(_ functionName: String, with parameters: [Any] = []) {
        modules.forEach { try! $0.jx.context.eval("\(functionName)()") }
    }

    /// Loads a module from a string of code.
    /// Automatically registers the module.
    /// - Parameter code: The code to load.
    public func loadCode(_ code: String) -> Void {
        let loaded = JSModuleLoader(schema).loadCode(code)
        register(loaded)
    }

    /// Loads a module from a file.
    /// Automatically registers the module.
    /// - Parameter path: The path to the file.
    public func loadFile(_ path: String) -> Void {
        let loaded = JSModuleLoader(schema).loadFile(path)
        register(loaded)
    }

    /// Loads a module from a file located in a bundle.
    /// Automatically registers the module.
    /// - Parameter path: The path to the file.
    /// - Parameter bundle: The bundle to load the file from. Use Bundle.module to load from the current project.
    public func loadRelativeFile(_ path: String, _ bundle: Bundle) -> Void {
        let loaded = JSModuleLoader(schema).loadRelativeFile(path, bundle)
        register(loaded)
    }

    /// Loads all modules from a directory.
    /// Automatically registers the modules.
    /// - Parameter path: The path to the directory.
    public func loadDirectory(_ path: String) -> Void {
        let loaded = JSModuleLoader(schema).loadDirectory(path)
        register(loaded)
    }

    /// Loads all modules from a directory located in a bundle.
    /// Automatically registers the modules.
    /// - Parameter path: The path to the directory.
    /// - Parameter bundle: The bundle to load the directory from. Use Bundle.module to load from the current project.
    public func loadRelativeDirectory(_ path: String, _ bundle: Bundle) -> Void {
        let loaded = JSModuleLoader(schema).loadRelativeDirectory(path, bundle)
        register(loaded)
    }

}