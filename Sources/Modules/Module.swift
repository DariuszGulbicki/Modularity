import Foundation

/// Class representing a module.
/// Can be overridden to create custom modules.
/// A module is a bundle of code that can be loaded and unloaded at runtime.
open class Module: NSObject {
    
    public required override init() {
        super.init()
    }
    
}