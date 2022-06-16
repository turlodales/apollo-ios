#if !COCOAPODS
import ApolloAPI
#endif
import Foundation

extension Selection.Field {
  public func cacheKey(with variables: GraphQLOperation.Variables?) throws -> String {
    if let arguments = arguments,
       case let argumentValues = try InputValue.evaluate(arguments, with: variables),
       argumentValues.apollo.isNotEmpty {
      let argumentsKey = orderIndependentKey(for: argumentValues)
      return "\(name)(\(argumentsKey))"
    } else {
      return name
    }
  }

  private func orderIndependentKey(for object: JSONObject) -> String {
    return object.sorted { $0.key < $1.key }.map {
      switch $0.value {
      case let object as JSONObject:
        return "[\($0.key):\(orderIndependentKey(for: object))]"
      case let array as [JSONObject]:
        return "\($0.key):[\(array.map { orderIndependentKey(for: $0) }.joined(separator: ","))]"
      case let array as [JSONValue]:
        return "\($0.key):[\(array.map { String(describing: $0.base) }.joined(separator: ", "))]"
      case is NSNull:
        return "\($0.key):null"
      default:
        return "\($0.key):\($0.value.base)"
      }
    }.joined(separator: ",")
  }
}

extension InputValue {
  private static func evaluate(
    _ value: AnyHashable,
    with variables: GraphQLOperation.Variables?
  ) throws -> JSONValue? {
    switch value {
    case let string as String:
      if string.hasPrefix("$") {
        guard let value = variables?[string] else {
          throw GraphQLError("Variable \"\(string)\" was not provided.")
        }
        return value.jsonEncodableValue?.jsonValue
      } else {
        return string
      }

    case let value as AnyScalarType:
      return value.jsonValue

    case let array as [AnyHashable]:
      return try InputValue.evaluate(array, with: variables)

    case let dictionary as [String: AnyHashable]:
      return try InputValue.evaluate(dictionary, with: variables)

    case is NSNull:
      return NSNull()

    default:
      return nil    
    }
  }

  fileprivate static func evaluate(
    _ values: [AnyHashable],
    with variables: GraphQLOperation.Variables?
  ) throws -> [JSONValue] {
    try values.compactMap { try evaluate($0, with: variables) }
  }

  fileprivate static func evaluate(
    _ values: [String: AnyHashable],
    with variables: GraphQLOperation.Variables?
  ) throws -> JSONObject {
    try values.compactMapValues { try evaluate($0, with: variables) }
  }
}
