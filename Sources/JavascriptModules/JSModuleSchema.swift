import JXKit

/// Class for validation of JavaScript modules.
/// Schema contains only minimal number of properties.
/// So for example property author that is not in the schema will not cause validation to fail.
/// However, if a property is in the schema, it must be of the correct type.
/// Can be used to enforce a schema on modules and avoid runtime errors.
public class JSModuleSchema {

    /// Enum containing all valid types for a schema.
    /// Any is a special type that will accept any value. However, it will still check if the property exists.
    public enum JSType {

        case string
        case number
        case boolean
        case array
        case object
        case function
        case null
        case undefined
        case any

        /// Can be used to check if a value matches the type.
        /// - Parameter jx: The value to check.
        /// - Returns: True if the value matches the type, false otherwise.
        public func check(_ jx: JXValue) -> Bool {
            switch self {
             case .string:
                return jx.isString
            case .number:
                return jx.isNumber
            case .boolean:
                return jx.isBoolean
            case .array:
                return jx.isArray
            case .object:
                return jx.isObject
            case .function:
                return jx.isFunction
            case .null:
                return jx.isNull
            case .undefined:
                return jx.isUndefined
            case .any:
                return true
            }
        }
            
    }

    /// Dictionary containing all properties and their types.
    /// If a property is not in the dictionary, it will not cause validation to fail.
    /// However, if a property is in the dictionary, it must be of the correct type.
    private let values: [String: JSType]

    /// Creates a new schema.
    /// - Parameter values: Dictionary containing all properties and their types.
    public init(values: [String: JSType]? = nil) {
        if values == nil {
            self.values = [:]
        } else {
            self.values = values!
        }
    }

    /// Adds a property to the schema.
    /// - Parameter name: The name of the property.
    /// - Parameter type: The type of the property.
    /// - Returns: The updated schema.
    public func expectValue(_ name: String, _ type: JSType) -> JSModuleSchema {
        var values = self.values
        values[name] = type
        return JSModuleSchema(values: values)
    }

    /// Adds a function to the schema.
    /// It is not possible to check the parameters or return type of the function.
    /// This function is equivalent to `expectValue(name, .function)`.
    /// - Parameter name: The name of the function.
    /// - Returns: The updated schema.
    public func expectFunction(_ name: String) -> JSModuleSchema {
        var values = self.values
        values[name] = .function
        return JSModuleSchema(values: values)
    }

    /// Validates a module against the schema.
    /// Checks if all properties are present and if they are of the correct type.
    /// - Parameter jx: The module to validate.
    /// - Returns: True if the module is valid, false otherwise.
    public func validate(_ jx: JXValue) -> Bool {
        for (name, type) in values {
            do {
                let val = try jx.context.eval(name)
                if (type != .any && !type.check(val)) {
                    return false
                }
            } catch {
                return false
            }
        }
        return true
    }

}