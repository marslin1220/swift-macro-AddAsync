# swift-macro-AddAsync

A swift macro creates an async function from a function returning a Promise

if you have a function which returns a Promise type:
```Swift
func test(arg1: String, arg2: Int) -> Promise<String> {
    .value("hello world!")
}
```

add the macro `@AddAsync` in front of the function:
```Swift
@AddAsync
func test(arg1: String, arg2: Int) -> Promise<String> {
    .value("hello world!")
}
```

and then will get another identical function name which return the value asynchronously.
```Swift
func test(arg1: String, arg2: Int) async throws -> String {
  try await withCheckedThrowingContinuation { continuation in
    self.test(arg1: arg1, arg2: arg2)
      .done {
        continuation.resume(returning: $0)
      }
      .catch {
        continuation.resume(throwing: $0)
      }
  }
}
```
