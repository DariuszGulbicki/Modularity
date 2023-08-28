import Foundation

// TODO: Fix relative loading
/// Class responsible for loading modules.
public class ModuleLoader<T: Module> {

    /// The bundle to load modules from.
    private let bundle = Bundle.main

    /// Creates a new module loader for the given module type.
    /// - Parameter module: The module type.
    /// - Returns: The created module loader.
    public static subscript(module: T.Type) -> ModuleLoader<T> {
        return ModuleLoader<T>()
    }

    /// Loads a module with the given name.
    /// Can be used as a subscript to quickly load modules.
    /// - Parameter className: The name of the module to load. Use Bundle.Class format. For Example: `MyAwesomeProject.MyModule`.
    /// - Returns: The loaded module.
    public subscript(_ className: String) -> T? {
        return try? load(className: className)
    }

    /// Loads multiple modules with the given names.
    /// Can be used as a subscript to quickly load modules.
    /// - Parameter classNames: The names of the modules to load. Use Bundle.Class format. For Example: `MyAwesomeProject.MyModule`.
    /// - Returns: The loaded modules.
    public subscript(_ classNames: String...) -> [T]? {
        return try? loadMultiple(classNames: classNames)
    }

    /// Loads multiple modules with the given names.
    /// - Parameter classNames: The names of the modules to load. Use Bundle.Class format. For Example: `MyAwesomeProject.MyModule`.
    /// - Returns: The loaded modules.
    public func load(classNames: String...) -> [T]? {
        return try? loadMultiple(classNames: classNames)
    }

    /// Loads multiple modules with the given names.
    /// - Parameter classNames: The names of the modules to load. Use Bundle.Class format. For Example: `MyAwesomeProject.MyModule`.
    /// - Returns: The loaded modules.
    /// - Throws: ModuleLoadingError if a module could not be loaded.
    public func loadMultiple(classNames: [String]) throws -> [T] {
        return classNames.map { try! load(className: $0) }
    }

    /// Loads a module with the given class name.
    /// - Parameter className: The name of the module to load. Use Bundle.Class format. For Example: `MyAwesomeProject.MyModule`.
    /// - Returns: The loaded module.
    /// - Throws: ModuleLoadingError if the module could not be loaded.
    public func load(className: String) throws -> T {
        guard let moduleClass = NSClassFromString(className) as? T.Type else {
            throw ModuleLoadingError<T>("Could not load module \(className)")
        }
        return moduleClass.init()
    }

    /// Returns all files in the given directory.
    /// Used for loading modules from a directory.
    /// 
    /// `This method is deprecated. Use Bundle based filesystem lookup instead.`
    /// 
    /// - Parameter package: The package to load modules from.
    /// - Parameter directory: The directory to load modules from.
    /// - Returns: An array containing all files in the directory.
    @available(*, deprecated, message: "No longer needed. Use Bundle based filesystem lookup instead.")
    private func getFilesInDirectory(_ package: String, _ directory: String) -> [URL] {
        if let directoryURL = Bundle.main.url(forResource: "\(package).build/\(directory)", withExtension: nil) {
            do {
                return try FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
            } catch {
                return []
            }
        }
        return []
    }

    /// Loads all modules from the given directory.
    /// 
    /// `This method has been marked as deprecated due to its misleading name. It does not load modules from .swift files.
    /// It loads modules from .d files. Dynamic loading of .swift files is impossible.
    /// There are no plans to remove this method for compatibility reasons.`
    /// - Parameter directory: The directory to load modules from.
    /// - Parameter package: The package to load modules from.
    /// - Returns: An array containing all loaded modules.
    @available(*, deprecated, message: "Misleading and works only in very specific cases. Dynamic loading of .swift files is impossible. There are no plans to remove this method.")
    public func loadFromDirectory(_ directory: String, _ package: String? = nil) -> [T] {
        let package = package ?? getCurrentProjectName()!
        let files = getFilesInDirectory(package, "Modules")
        var modules: [T] = []
        for file in files {
            if (file.path.suffix(2) == ".d") {
                guard let module = try? load(className: "\(package).\(file.lastPathComponent.dropLast(2))") else {
                    continue
                }
                modules.append(module)
            }
        }
        return modules
    }

    /// Creates the module manager for this Loader module type.
    /// - Returns: The module manager.
    public func getManager() -> ModuleManager<T> {
        return ModuleManager[T.self]
    }

    /// Returns the name of the current project.
    /// 
    /// `This method is deprecated. Use Bundle.main.bundleIdentifier instead.`
    /// 
    /// - Returns: The name of the current project.
    @available(*, deprecated, message: "Use Bundle.main.bundleIdentifier instead.")
    private func getCurrentProjectName() -> String? {
        return bundle.bundleIdentifier
    }

}