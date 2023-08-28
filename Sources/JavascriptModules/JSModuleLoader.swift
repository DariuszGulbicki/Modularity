import Foundation
import JXKit

/// Class for loading JavaScript modules.
/// Can be used with static methods or by creating an instance.
/// Creation of an instance allows for loading modules with a schema.
/// Use JSModuleSchema() for an empty schema that accepts all modules.
public class JSModuleLoader {

    /// Loads a module from a string of code.
    /// - Parameter code: The code to load.
    /// - Parameter context: The Javascript context to load the module into. Creates a new context if none is provided.
    /// - Returns: The loaded module.
    public static func loadCode(_ code: String, _ context: JXContext = JXContext()) throws -> JSModule {
        return try! JSModule(context.eval(code))
    }

    /// Loads a module from a file.
    /// - Parameter path: The path to the file.
    /// - Parameter context: The Javascript context to load the module into. Creates a new context if none is provided.
    /// - Returns: The loaded module.
    public static func loadFile(_ path: String, _ context: JXContext = JXContext()) throws -> JSModule {
        let fileContents = try! String(contentsOfFile: path)
        return try! JSModule(context.eval(fileContents))
    }

    /// Loads a module from a file located in a bundle.
    /// - Parameter path: The path to the file.
    /// - Parameter bundle: The bundle to load the file from. Use Bundle.module to load from the current project.
    /// - Parameter context: The Javascript context to load the module into. Creates a new context if none is provided.
    /// - Returns: The loaded module.
    public static func loadRelativeFile(_ path: String, _ bundle: Bundle, _ context: JXContext = JXContext()) -> JSModule {
        let url = bundle.url(forResource: path, withExtension: "js")!
        let fileContents = try! String(contentsOfFile: url.path)
        return try! JSModule(context.eval(fileContents))
    }

    /// Loads all modules from a directory.
    /// - Parameter path: The path to the directory.
    /// - Parameter context: The Javascript context to load the module into. Creates a new context if none is provided.
    /// - Returns: The loaded modules.
    public static func loadDirectory(_ path: String, _ context: JXContext = JXContext()) -> [JSModule] {
        var result = [JSModule]()
        let files = try! FileManager.default.contentsOfDirectory(atPath: path)
        for file in files {
            let fileContents = try! String(contentsOfFile: file)
            result.append(JSModule(try! context.eval(fileContents)))
        }
        return result
    }

    /// Loads all modules from a directory located in a bundle.
    /// - Parameter path: The path to the directory.
    /// - Parameter bundle: The bundle to load the directory from. Use Bundle.module to load from the current project.
    /// - Parameter context: The Javascript context to load the module into. Creates a new context if none is provided.
    /// - Returns: The loaded modules.
    public static func loadRelativeDirectory(_ path: String, _ bundle: Bundle, _ context: JXContext = JXContext()) -> [JSModule] {
        let url = bundle.url(forResource: path, withExtension: nil)!
        var result = [JSModule]()
        let files = try! FileManager.default.contentsOfDirectory(atPath: url.path)
        for file in files {
            let fileContents = try! String(contentsOfFile: url.appendingPathComponent(file).path)
            result.append(JSModule(try! context.eval(fileContents)))
        }
        return result
    }

    /// Creates a new module loader with the given schema.
    /// - Parameter schema: The schema to use for validating modules.
    /// - Returns: A new module loader.
    public subscript(_ schema: JSModuleSchema) -> JSModuleLoader {
        return JSModuleLoader(schema)
    }

    /// The schema to use for validating modules.
    let schema: JSModuleSchema

    /// The Javascript context to load modules into.
    public var context = JXContext()

    /// Creates a new module loader with the given schema.
    public init(_ schema: JSModuleSchema) {
        self.schema = schema
    }

    /// Loads a module from a string of code.
    /// - Parameter code: The code to load.
    /// - Returns: The loaded module.
    public func loadCode(_ code: String) -> JSModule {
        return validateSchema(try! JSModuleLoader.loadCode(code, context))
    }

    /// Loads a module from a file.
    /// - Parameter path: The path to the file.
    /// - Returns: The loaded module.
    public func loadFile(_ path: String) -> JSModule {
        return validateSchema(try! JSModuleLoader.loadFile(path, context))
    }

    /// Loads a module from a file located in a bundle.
    /// - Parameter path: The path to the file.
    /// - Parameter bundle: The bundle to load the file from. Use Bundle.module to load from the current project.
    /// - Returns: The loaded module.
    public func loadRelativeFile(_ path: String, _ bundle: Bundle) -> JSModule {
        return validateSchema(JSModuleLoader.loadRelativeFile(path, bundle, context))
    }

    /// Loads all modules from a directory.
    /// - Parameter path: The path to the directory.
    /// - Returns: The loaded modules.
    public func loadDirectory(_ path: String) -> [JSModule] {
        return validateSchema(JSModuleLoader.loadDirectory(path, context))
    }

    /// Loads all modules from a directory located in a bundle.
    /// - Parameter path: The path to the directory.
    /// - Parameter bundle: The bundle to load the directory from. Use Bundle.module to load from the current project.
    /// - Returns: The loaded modules.
    public func loadRelativeDirectory(_ path: String, _ bundle: Bundle) -> [JSModule] {
        return validateSchema(JSModuleLoader.loadRelativeDirectory(path, bundle, context))
    }

    /// Validates a module against the schema.
    /// - Parameter module: The module to validate.
    /// - Returns: The validated module.
    private func validateSchema(_ module: JSModule) -> JSModule {
        if schema.validate(module.jx) {
            return module
        } else {
            fatalError("Module does not match schema")
        }
    }

    /// Validates multiple modules against the schema.
    /// - Parameter modules: The modules to validate.
    /// - Returns: The validated modules.
    private func validateSchema(_ modules: [JSModule]) -> [JSModule] {
        return modules.filter { schema.validate($0.jx) }
    }

}