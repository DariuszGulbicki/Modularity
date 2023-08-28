import JXKit

@available(*, deprecated, message: "Use JXKit provided JXValue instead.")
/// Wrapper for JXValue that allows for easy conversion from JavaScript to Swift.
/// 
/// `This class is deprecated. Use JXKit provided JXValue instead.`
public class JSOutput: CustomStringConvertible {

    /// Returns the description of the value.
    public var description: String {
        return string()
    }

    /// The underlying JXValue.
    let jx: JXValue

    /// Creates a new JSOutput.
    /// - Parameter jx: The underlying JXValue.
    public init(_ jx: JXValue) {
        self.jx = jx
    }

    /// Returns the value as a bool.
    public func bool() -> Bool {
        return jx.bool
    }

    /// Returns the value as an int.
    public func int() -> Int {
        return try! jx.int
    }

    /// Returns the value as a double.
    public func double() -> Double {
        return try! jx.double
    }

    /// Returns the value as a string.
    public func string() -> String {
        return try! jx.string
    }

    /// Returns the value as a date.
    public func array() -> [JSOutput] {
        return try! jx.array.map(JSOutput.init)
    }

    /// Cheks if the value is null.
    public func isNull() -> Bool {
        return jx.isNull
    }

    /// Cheks if the value is undefined.
    public func isUndefined() -> Bool {
        return jx.isUndefined
    }

    /// Cheks if the value is an Object.
    public func isObject() -> Bool {
        return jx.isObject
    }

    /// Cheks if the value is a function.
    public func isFunction() -> Bool {
        return jx.isFunction
    }

    /// Cheks if the value is a string.
    public func isString() -> Bool {
        return jx.isString
    }

    /// Cheks if the value is a number.
    public func isNumber() -> Bool {
        return jx.isNumber
    }

    /// Cheks if the value is a date.
    public func isDate() -> Bool {
        return try! jx.isDate
    }

    /// Calls the value as a function.
    /// - Parameter args: The arguments to pass to the function.
    public func call(_ args: [Any]) -> JSOutput {
        return JSOutput(try! jx.call(withArguments: args))
    }

}