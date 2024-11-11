import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

final class BarrierQueueProtectedTests: XCTestCase {
    func testBarrierQueueProtectedMacro_macroAnnotatesFunction() throws {
#if canImport(BarrierQueueProtectedMacros)
        assertMacroExpansion(
            """
            class Tests: XCTTestCase {
                @BarrierQueueProtected
                func foo() -> Bool { true }
            }
            """,
            expandedSource: """
            class Tests: XCTTestCase {
                func foo() -> Bool { true }
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "@BarrierQueueProtected only works on variables", line: 2, column: 5)
            ],
            macros: testMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
    
    func testBarrierQueueProtectedMacro_macroAnnotatesComputedProperty() throws {
        #if canImport(BarrierQueueProtectedMacros)
        assertMacroExpansion(
            """
            class Tests: XCTTestCase {
                @BarrierQueueProtected
                var foo: Int {
                    100
                }
            }
            """,
            expandedSource: """
            class Tests: XCTTestCase {
                var foo: Int {
                    100
                }
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "@BarrierQueueProtected only works on stored properties", line: 2, column: 5),
                DiagnosticSpec(message: "@BarrierQueueProtected only works on stored properties", line: 2, column: 5)
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testBarrierQueueProtectedMacro_macroAnnotatesStoredProperty() throws {
        #if canImport(BarrierQueueProtectedMacros)
        assertMacroExpansion(
            """
            class Tests: XCTTestCase {
                @BarrierQueueProtected
                var foo: Int 
            }
            """,
            expandedSource:
            """
            class Tests: XCTTestCase {
                var foo: Int  {
                    get {
                        fooQueue.sync {
                            return _foo
                        }
                    }
                    set {
                        fooQueue.sync(flags: .barrier) {
                            _foo = newValue
                        }
                    }
                }

                private let fooQueue = DispatchQueue(label: "Barrier Queue for foo", attributes: .concurrent)

                private var _foo: Int
            }
            """,
            diagnostics: [],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
