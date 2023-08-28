import Foundation
import PythonKit

/// A class for caching Python code for loading via import.
public class PyCache {

    /// The directory where cached files are stored.
    public static let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("Modularity/PyModules")

    /// A dictionary containing all cached modules together with their UUID.
    private static var cached = [String: PyModule?]()

    /// Caches the given code and returns the UUID of the cached file.
    /// - Parameter code: The code to cache.
    /// - Returns: The UUID of the cached file.
    public static func cache(_ code: String) -> String {
        let moduleUUID = UUID().uuidString
        let cacheFile = cacheDirectory.appendingPathComponent(moduleUUID).appendingPathExtension("py")
        try! code.write(to: cacheFile, atomically: true, encoding: .utf8)
        cached[moduleUUID] = nil
        return moduleUUID
    }

    /// Loads the cached module with the given UUID.
    /// - Parameter moduleUUID: The UUID of the module to load.
    /// - Parameter sys: The sys module to use for loading the module.
    /// - Returns: The loaded module.
    public static func load(_ moduleUUID: String, _ sys: PythonObject = Python.import("sys")) -> PyModule {
        sys.path.append(cacheDirectory.path)
        cached[moduleUUID] = PyModule(Python.import(moduleUUID))
        sys.path.remove(cacheDirectory.path)
        return cached[moduleUUID]!!
    }

    /// Clears the cache and removes all files cached by this program.
    /// Will not remove files cached by other programs or other sessions of this program.
    /// 
    /// `This method should be called at the end of the program to prevent the cache from growing too large.
    /// Clearing the cache is safe as long as the modules are not needed anymore.`
    /// - Parameter moduleUUID: The UUID of the module to clear.
    public static func clear() -> Void {
        for moduleUUID in cached.keys {
            clear(moduleUUID)
        }
        cached = [String: PyModule?]()
    }

    /// Clears the cache and removes the specific file cached by this program with the given UUID.
    /// Will not remove any other files and will not modify the pycache folder.
    /// - Parameter moduleUUID: The UUID of the module to clear.
    public static func clear(_ moduleUUID: String) -> Void {
        let cacheFile = cacheDirectory.appendingPathComponent(moduleUUID).appendingPathExtension("py")
        try! FileManager.default.removeItem(at: cacheFile)
        cached[moduleUUID] = nil
    }

    /// Removes the cache directory and all files cached by `ALL` programs.
    /// This method is dangerous and should not be used unless you know what you are doing.
    /// Wrong usage of this method can lead to data loss and can cause other programs to crash.
    ///
    /// `This method has been marked as deprecated because of its dangerous nature. However, there are no plans to remove it. It is still used for development and testing.`
    @available(*, deprecated, message: "This method is dangerous and SHOULD NOT BE USED unless you know what you are doing. Wrong usage of this method can lead to data loss and can cause other programs to crash.")
    public static func delete() -> Void {
        try! FileManager.default.removeItem(at: cacheDirectory)
    }

}