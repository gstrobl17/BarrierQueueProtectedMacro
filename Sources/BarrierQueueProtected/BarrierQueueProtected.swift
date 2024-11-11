// The Swift Programming Language
// https://docs.swift.org/swift-book

@attached(peer, names: prefixed(_), suffixed(Queue))
@attached(accessor)
public macro BarrierQueueProtected() = #externalMacro(module: "BarrierQueueProtectedMacros", type: "BarrierQueueProtectedMacro")
