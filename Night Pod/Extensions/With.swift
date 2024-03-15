// Stolen from splintr - thanks splintr
/// Modifies a value using a function.
/// - Parameters:
///   - value: Any value.
///   - f: A function used to modify the value. The function will receive a reference to the value.
/// - Returns: The modified value.
public func with<T>(_ value: T, _ function: (inout T) -> Void) -> T {
	var value = value
	function(&value)
	return value
}
