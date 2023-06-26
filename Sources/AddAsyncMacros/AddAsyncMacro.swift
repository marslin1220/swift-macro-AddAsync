import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

enum AsyncError: Error, CustomStringConvertible {
    case onlyFunction
    case onlyPromise

    var description: String {
        switch self {
        case .onlyFunction:
            return "@AddAsync can be attached only to functions."
        case .onlyPromise:
            return "@AddAsync can be attached only to functions returning Promise<Result>."
        }
    }
}

public struct AddAsyncMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let functionDecl = declaration.as(FunctionDeclSyntax.self) else {
            throw AsyncError.onlyFunction
        }

        guard let signature = functionDecl.signature.as(FunctionSignatureSyntax.self) else { return [] }

        guard let returnType = signature.output?.returnType.as(SimpleTypeIdentifierSyntax.self),
              returnType.name.text == "Promise"
        else {
            throw AsyncError.onlyPromise
        }

        guard let promiseTypeName = returnType.genericArgumentClause?
            .arguments.first?
            .argumentType.as(SimpleTypeIdentifierSyntax.self)?
            .name
        else {
            return []
        }

        let parameters = signature.input.parameterList

        let functionArgs = parameters.map { parameter -> String in
            guard let paraType = parameter.type.as(SimpleTypeIdentifierSyntax.self)?.name else { return "" }
            return "\(parameter.firstName): \(paraType)"
        }.joined(separator: ", ")

        let calledArgs = parameters.map { "\($0.firstName): \($0.firstName)" }.joined(separator: ", ")

        return [
            """


            func \(functionDecl.identifier)(\(raw: functionArgs)) async throws -> \(promiseTypeName) {
              try await withCheckedThrowingContinuation { continuation in
                self.\(functionDecl.identifier)(\(raw: calledArgs))
                  .done {
                    continuation.resume(returning: $0)
                  }
                  .catch {
                    continuation.resume(throwing: $0)
                  }
              }
            }
            """
        ]
    }
}

@main
struct AddAsyncPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        AddAsyncMacro.self
    ]
}
