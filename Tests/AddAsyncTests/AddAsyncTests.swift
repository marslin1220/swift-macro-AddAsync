import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import AddAsyncMacros

let testMacros: [String: Macro.Type] = [
    "AddAsync": AddAsyncMacro.self
]

final class AddAsyncTests: XCTestCase {
    func test_returnStringTypePromise() {
        assertMacroExpansion(
        """
        @AddAsync
        func test(arg1: String, arg2: Int) -> Promise<String> {

        }
        """,
        expandedSource: """

        func test(arg1: String, arg2: Int) -> Promise<String> {

        }

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
        """,
        macros: testMacros
        )
    }

    func test_returnBoolTypePromise() {
        assertMacroExpansion(
        """
        @AddAsync
        func test(arg1: String, arg2: Int) -> Promise<Bool> {

        }
        """,
        expandedSource: """

        func test(arg1: String, arg2: Int) -> Promise<Bool> {

        }

        func test(arg1: String, arg2: Int) async throws -> Bool {
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
        """,
        macros: testMacros
        )
    }

    func test_returnVoidTypePromise() {
        assertMacroExpansion(
        """
        @AddAsync
        func test(arg1: String, arg2: Int) -> Promise<Void> {

        }
        """,
        expandedSource: """

        func test(arg1: String, arg2: Int) -> Promise<Void> {

        }

        func test(arg1: String, arg2: Int) async throws -> Void {
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
        """,
        macros: testMacros
        )
    }
}
