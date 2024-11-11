import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct BarrierQueueProtectedPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        BarrierQueueProtectedMacro.self,
    ]
}

