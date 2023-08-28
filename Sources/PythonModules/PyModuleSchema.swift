import PythonKit

/// Class used for schema validation of Python modules.
/// Allows to easily define a schema for a module and validate it.
/// Can be used to avoid errors when working with large amounts of modules.
/// Schema contains a minimal needed set of values and functions.
/// So for example if the module contains a function that is not in the schema, it will still be valid.
/// However, if the module does not contain a value that is in the schema or the value is of the wrong type, it will be invalid.
/// To disable schema validation, use an empty schema (PyModuleSchema()).
public class PyModuleSchema {

    /// Enum containing all valid types for a schema value.
    /// Any is a special type that allows any value.
    public enum PyType {

        case any
        case bool
        case int
        case float
        case string
        case list
        case dict
        case tuple
        case function
        case pyclass

        /// Checks if the given value is of the correct type.
        /// - Parameter value: The value to check.
        /// - Returns: True if the value is of the correct type, false otherwise.
        public func check(_ value: PythonObject) -> Bool {
            switch self {
            case .any:
                return true
            case .bool:
                return Python.type(value).description == "<class 'bool'>"
            case .int:
                return Python.type(value).description == "<class 'int'>"
            case .float:
                return Python.type(value).description == "<class 'float'>"
            case .string:
                return Python.type(value).description == "<class 'str'>"
            case .list:
                return Python.type(value).description == "<class 'list'>"
            case .dict:
                return Python.type(value).description == "<class 'dict'>"
            case .tuple:
                return Python.type(value).description == "<class 'tuple'>"
            case .function:
                return Python.type(value).description == "<class 'function'>"
            case .pyclass:
                return Python.type(value).description == "<class 'type'>"
            }
        }
            
    }

    /// Dictionary containing all values and their types.
    let values: [String: PyType]

    /// Creates a new PyModuleSchema with the given values.
    public init(values: [String: PyType]? = nil) {
        if values == nil {
            self.values = [:]
        } else {
            self.values = values!
        }
    }

    /// Adds the given value to the schema.
    /// This value must be present in the module for it to be loaded.
    /// - Parameter name: The name of the value.
    /// - Parameter type: The type of the value.
    /// - Returns: The updated schema.
    public func expectValue(_ name: String, _ type: PyType) -> PyModuleSchema {
        var values = self.values
        values[name] = type
        return PyModuleSchema(values: values)
    }

    /// Adds the given function to the schema.
    /// This function must be present in the module for it to be loaded.
    /// It is equivalent to `expectValue(name, .function)`.
    /// It is impossible to check the parameters and return type of the function.
    /// - Parameter name: The name of the function.
    /// - Returns: The updated schema.
    public func expectFunction(_ name: String) -> PyModuleSchema {
        var values = self.values
        values[name] = .function
        return PyModuleSchema(values: values)
    }

    /// Validates the given module against the schema.
    /// Checks if all values and functions are present and of the correct type.
    /// - Parameter module: The module to validate.
    /// - Returns: True if the module is valid, false otherwise.
    public func validate(_ module: PythonObject) -> Bool {
        for (name, type) in values {
            if Python.hasattr(module, name) == PythonObject(true) {
                let obj = Python.getattr(module, name)
                if (!type.check(obj)) {
                    return false
                }
            } else {
                return false
            }
        }
        return true
    }

}