import Foundation

public class ModuleLoader<T: Module> {

    private let bundle = Bundle.main

    public static subscript(module: T.Type) -> ModuleLoader<T> {
        return ModuleLoader<T>()
    }

    public subscript(_ className: String) -> T? {
        return try? load(className: className)
    }

    public subscript(_ classNames: String...) -> [T]? {
        return try? loadMultiple(classNames: classNames)
    }

    public func load(classNames: String...) -> [T]? {
        return try? loadMultiple(classNames: classNames)
    }

    public func loadMultiple(classNames: [String]) throws -> [T] {
        return classNames.map { try! load(className: $0) }
    }

    public func load(className: String) throws -> T {
        guard let moduleClass = NSClassFromString(className) as? T.Type else {
            throw ModuleLoadingError<T>("Could not load module \(className)")
        }
        return moduleClass.init()
    }

    
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

    public func getManager() -> ModuleManager<T> {
        return ModuleManager[T.self]
    }

    private func getCurrentProjectName() -> String? {
        return bundle.bundleIdentifier
    }

}