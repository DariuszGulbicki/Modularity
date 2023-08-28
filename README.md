# Modularity

**Module loader and manager for swift.**

## Features

* Quickly and easily load modules via their identifier or from a directory.
* Use module manager to manage large amounts of modules.
* Quick to use.
* Easy syntax.
* Supports grouping modules.
* Supports JavaScript modules.
* Supports Python modules.
* Cross platform.

## Module type support

- [x] Swift
- [x] Javascript
- [x] Python

## Installation

### Swift Package Manager

```swift
.package(url: "https://github.com/DariuszGulbicki/Modularity", from: "1.0.0")
```

## Usage

### Creating loadable modules

To create a loadable module, simply create a class that extends the `Module` class.

```swift
public class MyModule: Module {

    public func myFunction() {
        print("Hello World!")
    }

}
```

### Loading modules

To load a module, simply use the `ModuleLoader` class.
You can use either the subscript or the `load` function.

```swift
let module = ModuleLoader[MyModule.self]["MyProject.MyModule"]
module.myFunction()
```

### Grouping modules

To group modules, you can create a class extending `Module` that the other modules extend.\
Then you can use overridable functions to create a base for your modules.

```swift
open class EnableDisableModule: Module {

    open func enable() {
        // Enable module
    }

    open func disable() {
        // Disable module
    }

}

public class Notifier: EnableDisableModule {

    public func enable() {
        print("Modules enabled")
    }

    public func disable() {
        print("Modules disabled")
    }

}

public class HelloWorld: EnableDisableModule {

    public func enable() {
        print("Hello World!")
    }

    public func disable() {
        print("Goodbye World!")
    }

}
```

Now we can use the `ModuleLoader` to load all modules that extend `EnableDisableModule`.

```swift
// modules will be a list of loaded modules
// Each module will be in form of a EnableDisableModule object
let modules = ModuleLoader[EnableDisableModule.self]["MyProject.Notifier", "MyProject.HelloWorld"]
modules.forEach { $0.enable() }
modules.forEach { $0.disable() }
```

### Module manager

To manage modules, you can use the `ModuleManager` class.\
You can use the `ModuleManager` to load modules from a directory, or to load modules from a list of identifiers.
Then you have the option to run a function on all loaded modules or on a filtered set of modules.\
\
*We will use the modules from the previous example.*

```swift
// Create a module manager
let manager = ModuleManager[EnableDisableModule.self] // or ModuleLoader[EnableDisableModule.self].getManager()

// Load modules
try! manager.load("MyProject.Notifier", "MyProject.HelloWorld")

// Run enable function on all modules
manager[{ $0.enable() }]

// Filter modules
// This will return a list of modules that extend Notifier
let filtered = manager[{ $0 is Notifier }]

// Run disable function on filtered modules
// We will run disable function only on HelloWorld
manager[{ $0 is HelloWorld }, { $0.disable() }]
```

### Dynamic modules (Javascript, Python)

Modularity supports dynamic modules.\
You can load dynamic modules both directly from code and from files.\
\
Dynamic modules can be loaded without structure, but you can also use 'Schemas' to avoid errors when working with large amounts of modules\
Modules can also be loaded as 'relative' modules, i.e. from a bundle.\
Each module type has its own schema, loader and manager to make working with them as easy and intuitive as possible.\

#### Javascript

Start by importing the `JavascriptModules` module.

```swift
import JavascriptModules
```

Code below shows an example on how to load and work with javascript modules.

```swift
// Create module manager
let modules = JSModuleManager[
    /*
        Schema:
            name: string
            version: number
            hello: function
    */
    JSModuleSchema()
        .expectValue("name", .string)
        .expectValue("version", .number)
        .expectFunction("hello")
]
// Load all modules in the Resources/modules directory
modules.loadRelativeDirectory("modules", Bundle.module)
// Print all loaded modules
modules[{ print("Loaded \($0.name) (version: \($0.version))") }]
// Execute hello function on all modules
modules[{ $0("hello") }]
```

#### Python

Start by importing the `PythonModules` module.

```swift
import PythonModules
```

Code below shows an example on how to load and work with python modules.

```swift
// Create module manager
let modules = PyModuleManager[
    /*
        Schema:
            name: string
            version: float
            hello: function
    */
    PyModuleSchema()
        .expectValue("name", .string)
        .expectValue("version", .float)
        .expectFunction("hello")
]
// Load all modules in the Resources/modules directory
modules.loadRelativeDirectory("modules", Bundle.module)
// Print all loaded modules
modules[{ print("Loaded \($0.name) (version: \($0.version))") }]
// Execute hello function on all modules
modules[{ $0.hello() }]
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

## Authors

* **Dariusz Gulbicki** - *Initial work* - [DariuszGulbicki](https://dariuszgulbicki.pl)

## Contributing

If you have any ideas, feel free to contribute.\
To contribute, simply create a pull request.