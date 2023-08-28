import PythonKit

@dynamicCallable
@dynamicMemberLookup
/// Class representing a Python module.
/// Uses dynamic member lookup and dynamic callable to allow easy access to the module.
public class PyModule {

    /// The Python module. Can be used to access the PythonObject directly.
    let module: PythonObject

    /// Creates a new PyModule from the given PythonObject.
    /// - Parameter module: The PythonObject to use.
    public init(_ module: PythonObject) {
        self.module = module
    }

    /// Allows to dynamically access module members.
    /// - Parameter member: The member to access.
    /// - Returns: The member.
    public subscript(dynamicMember member: String) -> PythonObject {
        return module[dynamicMember: member]
    }

    /// Allows to dynamically call the module function.
    /// - Parameter args: The arguments to pass to the function.
    /// - Returns: The return value of the function.
    public func dynamicallyCall(withArguments args: [PythonObject]) -> PythonObject {
        return module(args)
    }

}