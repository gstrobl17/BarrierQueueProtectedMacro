import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public enum BarrierQueueProtectedMacroError: Error, CustomStringConvertible {
    case onlyWorksOnVariables(String)
    case onlyWorksOnStoredProperties(String)
    case bindingNotFound

    public var description: String {
        switch self {
        case .onlyWorksOnVariables(let name):
            return "\(name) only works on variables"
        case .onlyWorksOnStoredProperties(let name):
            return "\(name) only works on stored properties"
        case .bindingNotFound:
            return "Binding not found"
        }
    }
}

public struct BarrierQueueProtectedMacro: PeerMacro, AccessorMacro {
    
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self) else {
            throw BarrierQueueProtectedMacroError.onlyWorksOnVariables(node.trimmedDescription)
        }
        guard varDecl.bindings.first?.accessorBlock == nil else {
            throw BarrierQueueProtectedMacroError.onlyWorksOnStoredProperties(node.trimmedDescription)
        }
        guard let patternBinding = varDecl.bindings.first else {
            throw BarrierQueueProtectedMacroError.bindingNotFound
        }
        let variableName = patternBinding.pattern.trimmedDescription

        return [
            "private let \(raw: variableName)Queue = DispatchQueue(label: \"Barrier Queue for \(raw: variableName)\", attributes: .concurrent)",
            "private var _\(raw: variableName)\(patternBinding.typeAnnotation)"
        ]
    }

    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingAccessorsOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.AccessorDeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self) else {
            throw BarrierQueueProtectedMacroError.onlyWorksOnVariables(node.trimmedDescription)
        }
        guard varDecl.bindings.first?.accessorBlock == nil else {
            throw BarrierQueueProtectedMacroError.onlyWorksOnStoredProperties(node.trimmedDescription)
        }
        guard let patternBinding = varDecl.bindings.first else {
            throw BarrierQueueProtectedMacroError.bindingNotFound
        }
        let variableName = patternBinding.pattern.trimmedDescription

        return [
            """
            get {
                \(raw: variableName)Queue.sync {
                    return _\(raw: variableName) 
                }
            }
            set {
                \(raw: variableName)Queue.sync(flags: .barrier) {
                    _\(raw: variableName) = newValue
                }
            }
            """
        ]
    }

}
