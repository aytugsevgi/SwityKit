# SwityKit

## Benefits

🚀 Generates assertions to the debug log

🚀 Reduces test run time by ~40%

🚀 It prevents us from writing incomplete tests

🚀 Less mock code

🚀 Tests that it is invoked in the correct order.

## Installation

### Swift Package Manager

To integrate SwityKit into your Xcode project using Swift Package Manager, add it to the dependencies value of your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/aytugsevgi/SwityKit", from: "1.0.2")
]
```
## Example

### Mock

```swift
final class MockHomeViewController: HomeViewControllerInterface, MockAssertable {
    typealias MockIdentifier = MockHomeViewControllerElements
    var invokedList: [MockHomeViewControllerElements] = []

    var stubbedPreferredTabBarVisibility: TabBarVisibility!

    var preferredTabBarVisibility: TabBarVisibility {
        invokedList.append(.preferredTabBarVisibility)
        return stubbedPreferredTabBarVisibility
    }

    func viewDidLoad() {
        invokedList.append(.viewDidLoad)
    }
    
    func scroll(to indexPath: IndexPath) {
        invokedList.append(.scroll(to: indexPath))
    }
}

enum MockHomeViewControllerElements: MockEquatable {
    case preferredTabBarVisibility
    case viewDidLoad()
    case scroll(to: IndexPath)
}
```
### Test
