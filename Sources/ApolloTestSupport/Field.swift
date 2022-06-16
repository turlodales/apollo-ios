import ApolloAPI

@propertyWrapper
public struct Field<T> {

  let key: StaticString

  public init(_ field: StaticString) {
    self.key = field
  }

  public var wrappedValue: Self { self }

}

public typealias ArgumentField<T, Args: FieldArguments> = Field<Args>

open class FieldArguments {
  public typealias Arguments = [String: GraphQLOperationVariableValue]

  private weak var parent: AnyMock?
  private let fieldName: StaticString

  public required init(_ parent: AnyMock, fieldName: StaticString) {
    self.parent = parent
    self.fieldName = fieldName
  }

  public func key(for args: [String: GraphQLOperationVariableValue]) -> String {
    "\(fieldName)(\(CacheKeyComputation.argumentKey(for: args.jsonEncodableObject)))"
  }

  public func getValue<T: JSONEncodable>(for arguments: Arguments) -> T? {
    parent?._data[key(for: arguments)] as? T
  }

  public func set<T: JSONEncodable>(_ value: T?, for arguments: Arguments) {
    parent?._data[key(for: arguments)] = value
  }

  public func getValue(for arguments: Arguments) -> AnyMock? {
    parent?._data[key(for: arguments)] as? AnyMock
  }

  public func set(_ value: AnyMock?, for arguments: Arguments) {
    parent?._data[key(for: arguments)] = value
  }
}
