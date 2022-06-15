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
  public typealias KeyFromArgs = String

  weak var parent: AnyMock?
  let fieldName: StaticString

  public required init(_ parent: AnyMock, fieldName: StaticString) {
    self.parent = parent
    self.fieldName = fieldName
  }

  public func key(for args: [String: GraphQLOperationVariableValue]) -> KeyFromArgs {

  }

  public func set(_ value: T?, for key: KeyFromArgs) {
    parent?._data[key] = value
  }
}

//struct ArgResolver<T> {
//
//}
//
//@propertyWrapper
//public class ArgField<T, Args> {
//
//  let key: StaticString
//
//  public init(_ field: StaticString) {
//    self.key = field
//  }
//
//  public var wrappedValue: T? { nil }
//}
