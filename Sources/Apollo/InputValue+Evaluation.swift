#if !COCOAPODS
import ApolloAPI
#endif
import Foundation

extension Selection.Field {
  public func cacheKey(with variables: GraphQLOperation.Variables?) throws -> String {
    if let arguments = arguments,
       case let argumentValues = try InputValue.evaluate(arguments, with: variables),
       argumentValues.apollo.isNotEmpty {
      let argumentsKey = CacheKeyComputation.argumentKey(for: argumentValues)
      return "\(name)(\(argumentsKey))"
    } else {
      return name
    }
  }
}

extension InputValue {
  private func evaluate(with variables: GraphQLOperation.Variables?) throws -> JSONEncodable? {
    switch self {
    case let .variable(name):
      guard let value = variables?[name] else {
        throw GraphQLError("Variable \"\(name)\" was not provided.")
      }
      return value.jsonEncodableValue

    case let .scalar(value):
      return value

    case let .list(array):
      return try InputValue.evaluate(array, with: variables)

    case let .object(dictionary):
      return try InputValue.evaluate(dictionary, with: variables)

    case .null:
      return NSNull()
    }
  }

  fileprivate static func evaluate(
    _ values: [InputValue],
    with variables: GraphQLOperation.Variables?
  ) throws -> [JSONEncodable] {
    try values.compactMap { try $0.evaluate(with: variables) }
  }

  fileprivate static func evaluate(
    _ values: [String: InputValue],
    with variables: GraphQLOperation.Variables?
  ) throws -> JSONEncodableDictionary {
    try values.compactMapValues { try $0.evaluate(with: variables) }
  }
}
