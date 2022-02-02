@testable import ApolloCodegenLib

extension IR {

  public static func mock(schema: String, document: String) throws -> IR {
    let frontend = try GraphQLJSFrontend()
    let compilationResult = try frontend.compile(schema: schema, document: document)
    return .mock(compilationResult: compilationResult)
  }

  public static func mock(schema: String, documents: [String]) throws -> IR {
    let frontend = try GraphQLJSFrontend()
    let compilationResult = try frontend.compile(schema: schema, documents: documents)
    return .mock(compilationResult: compilationResult)
  }

  public static func mock(
    schemaName: String = "TestSchema",
    compilationResult: CompilationResult
  ) -> IR {
    return IR(schemaName: schemaName, compilationResult: compilationResult)
  }

}