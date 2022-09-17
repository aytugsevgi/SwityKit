# SwityKit

SwityKit is an infrastructure that makes easy unit test writing and aims to increase coverage.

Used with [SwityTestGenerator](https://github.com/aytugsevgi/SwityTestGenerator). This xcode source editor extension helps to mock generation.

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
You need to add to `Build Phases -> Link Binary With Libraries` for test targets. Also remove from main target.

<img width="742" alt="Screen Shot 2022-09-16 at 14 27 54" src="https://user-images.githubusercontent.com/33103753/190629320-8c54f598-5e2f-4e08-8ba0-d715ba70fc34.png">

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

```swift
final class HomeViewPresenterTests: XCTestCase, BaseTestCaseInterface {
    var mocks: [MockAssertable] { [view, delegate] }
    
    var view: MockHomeViewController!
    var delegate: MockHomeDelegate!
    var presenter: HomeViewPresenter!
    
    override func setUp() {
        super.setUp()
        view = .init()
        delegate = .init()
        presenter = .init(view: view)
    }
    
    override func tearDown() {
        super.tearDown()
        view.assertions("view")
        delegate.assertions("delegate")
        
        view = nil
        delegate = nil
        presenter = nil
    }
    
    func test_viewDidLoad_InvokesRequiredMethods() {
       invokedNothing()
       
       presenter.viewDidLoad()
       
       view.assertInvokes([.preferredTabBarVisibility,
                           .scroll(to: .init(item: 0, section: 1))])
       invokedNothing(excepts: [view])
    }
}
```
### Debug Log (Generation of assertions)

<img width="590" alt="Screen Shot 2022-09-16 at 00 40 25" src="https://user-images.githubusercontent.com/33103753/190513945-42c37b73-84e0-4aba-ba03-680370f6fc92.png">

- Manipulating test generation. If you want to change the output of a type, you can write extension with conform `CustomStringConvertable`.
```swift
extension User: CustomStringConvertable {
    public var description: String {
        ".init(name: \"\(self.name)\", age: \"\(self.age)\")"
    }
}
```
- If that type already conforms to `CustomStringConvertable`, you just need to override it.
```swift
extension NSAttributedString {
    public override var description: String {
        ".init(string: \"\(self.string)\")"
    }
}
```

## Deep Dive

### MockAssertable

This protocol must conform to mock classes. With this protocol, the mock class has an array called `invokedList`. The element of this array is the typealias that is expected to be defined with `MockIdentifier`.
```swift
final class MockHomeViewController: HomeViewControllerInterface, MockAssertable {
    typealias MockIdentifier = MockHomeViewControllerElements
    var invokedList: [MockHomeViewControllerElements] = []
    .
    .
    .
```
`MockIdentifier` type must be enum with conformed `MockEquatable`. Like `MockHomeViewControllerElements` example above.
```swift
enum MockHomeViewControllerElements: MockEquatable {
    ...
}
```
`MockAssertable` also has helpful public APIs.
- `assertInvokes()`: Tests that nothing was invoked from mock.
- `assertInvokes(_ givenInvokes: [MockIdentifier])`: Tests whether the elements in the array have been invoked. If it is missing or 
extra, it will give an error. It also warns you if the array is in the wrong order.
- `assertions(name: String)`: Generate assertions to debug log according to `invokedList` array. If you call on `override func tearDown()` it's generate correctly after run each test func.
- `tearDown()`: Deletes all elements of the invokedList array. It continues as nothing was invoked.

### MockEquatable

`MockEquatable` allows us to assert. It allows to get the String describing of the enum case in which it is conformed. Then it looks at the equality of these 2 strings when doing the comparison.

### BaseTestCaseInterface

This protocol must conform to test classes. Requests mocks from test class. Like,
```swift
final class HomeViewPresenterTests: XCTestCase, BaseTestCaseInterface {
    var mocks: [MockAssertable] { [view, delegate] }
    .
    .
    .
```
APIs it provides;
- `tearDownMocks()`: Empties the invokedList array of all mocks. It continues as if nothing was invoked.
- `invokedNothing(excepts: [BaseMockAssertable] = .empty)`: Shortcut assertion. Tests that the given in the test class's mocks array is not invoked at all. Does not check mocks given to `excepts`.
