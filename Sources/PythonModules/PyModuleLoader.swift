import Foundation
import PythonKit

/// A class used for loading Python modules.
/// Can be used via static methods or via instance with schema validation.
/// Only instance allows for schema validation.
/// To disable schema validation, use empty schema: `PyModuleLoader[PyModuleSchema()]`.
public class PyModuleLoader {

    /// Loads the given code as a module.
    /// - Parameter code: The code to load.
    /// - Parameter sys: The sys module to use for loading the module.
    /// - Returns: The loaded module.
    public static func loadCode(_ code: String, _ sys: PythonObject = Python.import("sys")) -> PyModule {
        let uuid = PyCache.cache(code)
        return PyCache.load(uuid)
    }

    /// Loads the given file as a module.
    /// - Parameter path: The path to the file to load.
    /// - Parameter sys: The sys module to use for loading the module.
    /// - Returns: The loaded module.
    public static func loadFile(_ path: String, _ sys: PythonObject = Python.import("sys")) -> PyModule {
        let url = URL(fileURLWithPath: path)
        let pathString = url.deletingPathExtension().deletingLastPathComponent().path
        sys.path.append(pathString)
        let module = Python.import(url.deletingPathExtension().lastPathComponent)
        sys.path.remove(pathString)
        return PyModule(module)
    }

    /// Loads the given file from a bundle as a module.
    /// - Parameter path: The path to the file to load.
    /// - Parameter bundle: The bundle to load the file from. Use `Bundle.module` for loading from the current project.
    /// - Parameter sys: The sys module to use for loading the module.
    /// - Returns: The loaded module.
    public static func loadRelativeFile(_ path: String, _ bundle: Bundle, _ sys: PythonObject = Python.import("sys")) -> PyModule {
        let url = bundle.url(forResource: path, withExtension: "py")!
        let pathString = url.deletingPathExtension().deletingLastPathComponent().path
        sys.path.append(pathString)
        let module = Python.import(url.deletingPathExtension().lastPathComponent)
        sys.path.remove(pathString)
        return PyModule(module)
    }

    /// Loads all files in the given directory as modules.
    /// Does not traverse subdirectories.
    /// - Parameter path: The path to the directory to load.
    /// - Parameter sys: The sys module to use for loading the modules.
    /// - Returns: The loaded modules.
    public static func loadDirectory(_ path: String, _ sys: PythonObject = Python.import("sys")) -> [PyModule] {
        var result = [PyModule]()
        let url = URL(fileURLWithPath: path)
        let files = try! FileManager.default.contentsOfDirectory(atPath: url.path)
        for file in files {
            result.append(loadFile(path + "/\(file)", sys))
        }
        return result
    }

    /// Loads all files in the given directory from a bundle as modules.
    /// Does not traverse subdirectories.
    /// - Parameter path: The path to the directory to load.
    /// - Parameter bundle: The bundle to load the files from. Use `Bundle.module` for loading from the current project.
    /// - Parameter sys: The sys module to use for loading the modules.
    /// - Returns: The loaded modules.
    public static func loadRelativeDirectory(_ path: String, _ bundle: Bundle, _ sys: PythonObject = Python.import("sys")) -> [PyModule] {
        let url = bundle.url(forResource: path, withExtension: nil)!
        let files = try! FileManager.default.contentsOfDirectory(atPath: url.path)
        var result = [PyModule]()
        for file in files {
            result.append(loadFile(url.path + "/\(file)", sys))
        }
        return result
    }

    /// Creates a new PyModuleLoader for the given schema.
    /// Can be supplied with Empty schema to disable schema validation.
    /// - Parameter schema: The schema to use for schema validation.
    /// - Returns: The created PyModuleLoader.
    public subscript(_ schema: PyModuleSchema) -> PyModuleLoader {
        return PyModuleLoader(schema)
    }

    /// Schema used for schema validation.
    let schema: PyModuleSchema

    /// The sys module to use for loading the modules.
    public var sys = Python.import("sys")

    /// Creates a new PyModuleLoader for the given schema.
    public init(_ schema: PyModuleSchema) {
        self.schema = schema
    }

    /// Loads the given code as a module.
    /// - Parameter code: The code to load.
    /// - Returns: The loaded module.
    public func loadCode(_ code: String) -> PyModule {
        return validateSchema(PyModuleLoader.loadCode(code, sys))
    }

    /// Loads the given file as a module.
    /// - Parameter path: The path to the file to load.
    /// - Returns: The loaded module.
    public func loadFile(_ path: String) -> PyModule {
        return validateSchema(PyModuleLoader.loadFile(path, sys))
    }

    /// Loads the given file from a bundle as a module.
    /// - Parameter path: The path to the file to load.
    /// - Parameter bundle: The bundle to load the file from. Use `Bundle.module` for loading from the current project.
    /// - Returns: The loaded module.
    public func loadRelativeFile(_ path: String, _ bundle: Bundle) -> PyModule {
        return validateSchema(PyModuleLoader.loadRelativeFile(path, bundle, sys))
    }

    /// Loads all files in the given directory as modules.
    /// Does not traverse subdirectories.
    /// - Parameter path: The path to the directory to load.
    /// - Returns: The loaded modules.
    public func loadDirectory(_ path: String) -> [PyModule] {
        return validateSchema(PyModuleLoader.loadDirectory(path, sys))
    }

    /// Loads all files in the given directory from a bundle as modules.
    /// Does not traverse subdirectories.
    /// - Parameter path: The path to the directory to load.
    /// - Parameter bundle: The bundle to load the files from. Use `Bundle.module` for loading from the current project.
    /// - Returns: The loaded modules.
    public func loadRelativeDirectory(_ path: String, _ bundle: Bundle) -> [PyModule] {
        return validateSchema(PyModuleLoader.loadRelativeDirectory(path, bundle, sys))
    }

    /// Validates the given module against the schema.
    /// - Parameter module: The module to validate.
    /// - Returns: The validated module.
    private func validateSchema(_ module: PyModule) -> PyModule {
        if schema.validate(module.module) {
            return module
        } else {
            fatalError("Module does not match schema")
        }
    }

    /// Validates multiple modules against the schema.
    /// - Parameter modules: The modules to validate.
    /// - Returns: The validated modules.
    private func validateSchema(_ modules: [PyModule]) -> [PyModule] {
        return modules.filter { schema.validate($0.module) }
    }

}