import Foundation

public enum CacheKeyComputation {
  /// Computs the arguments component of a cache key for a field with arguments.
  /// The arguments are sorted (ie. order independent) so that a field with the
  /// same argument values always has the same cache key regardless of argument order.
  public static func argumentKey(for arguments: JSONEncodableDictionary) -> String {
    return arguments.sorted { $0.key < $1.key }.map {
      switch $0.value {
      case let object as JSONEncodableDictionary:
        return "\($0.key):[\(argumentKey(for: object))]"
      case let array as [JSONEncodableDictionary]:
        return "\($0.key):[\(array.map { argumentKey(for: $0) }.joined(separator: ","))]"
      case let array as [JSONEncodable]:
        return "\($0.key):[\(array.map { String(describing: $0.jsonValue.base) }.joined(separator: ", "))]"
      case is NSNull:
        return "\($0.key):null"
      default:
        return "\($0.key):\($0.value.jsonValue.base)"
      }
    }.joined(separator: ",")
  }

}
