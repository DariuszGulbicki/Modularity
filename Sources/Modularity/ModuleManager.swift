public class ModuleManager<T: Module> {

    public static subscript(module: T.Type) -> ModuleManager<T> {
        return ModuleManager<T>()
    }

    private init() {

    }

    public subscript(filter: (T) -> Bool) -> T? {
        return getModule(filter)
    }

    public subscript(function: (T) -> Void) -> Void {
        execute(function)
    }

    public subscript(filter: (T) -> Bool, function: (T) -> Void) -> Void {
        if let module = getModule(filter) {
            function(module)
        }
    }

    private var modules: [T] = []

    public func register(_ module: T) {
        modules.append(module)
    }

    public func register(_ modules: [T]) {
        self.modules.append(contentsOf: modules)
    }

    public func unregister(_ module: T) {
        modules.removeAll { $0 === module }
    }

    public func getModule(_ filter: (T) -> Bool) -> T? {
        return modules.first(where: filter)
    }

    public func execute(_ function: (T) -> Void) {
        for module in modules {
            function(module)
        }
    }

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

    public func load(_ className: String) throws -> Void {
        let loaded = try! ModuleLoader[T.self].load(className: className)
        register(loaded)
    }

    public func load(_ classNames: String...) throws -> Void {
        let loaded = try! ModuleLoader[T.self].loadMultiple(classNames: classNames)
        register(loaded)
    }

    public func loadFromDirectory(_ directory: String, _ package: String? = nil) -> Void {
        let loaded = ModuleLoader[T.self].loadFromDirectory(directory, package)
        register(loaded)
    }

}