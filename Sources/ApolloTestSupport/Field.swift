import ApolloAPI

@propertyWrapper
public struct Field<T> {

  let key: StaticString

  public init(_ field: StaticString) {
    self.key = field
  }

  public var wrappedValue: Self { self }

}

open class ArgumentField<T: JSONEncodable> {
  public typealias Arguments = [String: GraphQLOperationVariableValue]

  weak var parent: AnyMock?
  let fieldName: StaticString

  public required init(_ parent: AnyMock, fieldName: StaticString) {
    self.parent = parent
    self.fieldName = fieldName
  }

  public func key(for args: [String: GraphQLOperationVariableValue]) -> String {
    "\(fieldName)(\(CacheKeyComputation.argumentKey(for: args.jsonEncodableObject)))"
  }

  public func getValue(for arguments: Arguments) -> T? {
    parent?._data[key(for: arguments)] as? T
  }

  public func set(_ value: T?, for arguments: Arguments) {
    parent?._data[key(for: arguments)] = value
  }
}
