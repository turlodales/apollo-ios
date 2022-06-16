import Foundation
import ApolloUtils

struct MockObjectTemplate: TemplateRenderer {
  /// IR representation of source [GraphQL Object](https://spec.graphql.org/draft/#sec-Objects).
  let graphqlObject: GraphQLObjectType

  /// Shared codegen configuration.
  let config: ReferenceWrapped<ApolloCodegenConfiguration>

  let ir: IR

  let target: TemplateTarget = .testMockFile

  var template: TemplateString {
    typealias FieldInfo = (
      name: String,
      type: String,
      arguments: [GraphQLFieldArgument]?,
      mockType: String
    )

    let objectName = graphqlObject.name.firstUppercased
    var allFields: [FieldInfo], argumentFields: [FieldInfo]

    for (fieldName, field) in ir.fieldCollector.collectedFields(for: graphqlObject) {
      let fieldInfo = (
        name: fieldName,
        type: field.type.rendered(containedInNonNull: true, inSchemaNamed: ir.schema.name),
        arguments: field.arguments,
        mockType: mockTypeName(for: field.type)
      )
    }

    return """
    extension \
    \(if: !config.output.schemaTypes.isInModule, "\(ir.schema.name.firstUppercased).")\
    \(objectName): Mockable {
      public static let __mockFields = MockFields()

      public typealias MockValueCollectionType = Array<Mock<\(objectName)>>
    
      public struct MockFields {
        \(fields.map {
          return """
          @Field<\($0.type)>("\($0.name)") public var \($0.name)
          """
        }, separator: "\n")
      }
    }

    public extension Mock where O == \(objectName) {
      convenience init(
        \(fields.map { "\($0.name): \($0.mockType)? = nil" }, separator: ",\n")
      ) {
        self.init()
        \(fields.map { "self.\($0.name) = \($0.name)" }, separator: "\n")
      }
    }
    """
  }

  private func mockTypeName(for type: GraphQLType) -> String {
    func nameReplacement(for type: GraphQLType) -> String? {
      switch type {
      case .entity(let graphQLCompositeType):
        switch graphQLCompositeType {
        case is GraphQLInterfaceType, is GraphQLUnionType:
          return "AnyMock"
        default:
          return "Mock<\(graphQLCompositeType.name)>"
        }
      case .scalar,
          .enum,
          .inputObject:
        return nil
      case .nonNull(let graphQLType),
          .list(let graphQLType):
        return nameReplacement(for: graphQLType)
      }
    }

    return type.rendered(
      containedInNonNull: true,
      replacingNamedTypeWith: nameReplacement(for: type),
      inSchemaNamed: ir.schema.name
    )
  }
  
}
