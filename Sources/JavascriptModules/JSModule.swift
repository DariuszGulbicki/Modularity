import JXKit

@dynamicCallable
@dynamicMemberLookup
public class JSModule {

    /// JavaScript context. This is the object that holds the JavaScript state.
    public let jx: JXValue

    /// Creates a new JavaScript module.
    /// - Parameter jx: JavaScript context.
    public init(_ jx: JXValue) {
        self.jx = jx
    }

    /// Allows easy access to JavaScript properties.
    /// Will not execute functions. Functions will be treated as properties.
    /// To execute functions, use the `dynamicallyCall(withArguments:)` or () method.
    /// - Parameter member: Name of the property.
    /// - Returns: The property.
    public subscript(dynamicMember member: String) -> JXValue {
        return try! jx.context.eval(member)
    }

    /// Allows for easy execution of JavaScript functions.
    /// First argument is the name of the function. All other arguments are passed to the function.
    /// If you start an argument with a `#`, it will be treated as a string.
    /// 
    /// `Example:`
    /// ```
    /// module.functionName("hello", "world")
    /// // is equivalent to:
    /// hello(world)
    /// ```
    ///
    /// But when you add # to the argument, it will be treated as a string.
    /// Adding # to the function name will not change it into a string.
    ///
    /// ```
    /// module.functionName("hello", "#world")
    /// // is equivalent to:
    /// hello("world")
    /// ```
    /// 
    /// - Parameter arguments: First argument is the name of the function.
    /// - Returns: The return value of the function.
    public func dynamicallyCall(withArguments arguments: [String]) -> JXValue {
        if (arguments.count == 0) {
            return jx
        } else {
            let stringifiedArguments = arguments.map { 
                if $0.starts(with: "#") {
                    return "\"\($0.dropFirst())\""
                } else {
                    return $0
                }
            }
            let argumentString = stringifiedArguments.dropFirst().joined(separator: ", ")
            return try! jx.context.eval(arguments[0] + "(" + argumentString + ")")
        }
    }

    /// Allows for access to submodules.
    /// 
    /// `Example:`
    /// ```
    /// module.submodule("Math").hypot("3", "4")
    /// // is equivalent to:
    /// Math.hypot(3, 4)
    /// ```
    /// - Parameter name: Name of the submodule.
    /// - Returns: The submodule as JSModule.
    public func submodule(_ name: String) -> JSModule {
        return JSModule(try! jx[name])
    }

}