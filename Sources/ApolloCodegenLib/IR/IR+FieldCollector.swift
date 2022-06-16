extension IR {

  class FieldCollector {

    private var collectedFields: [GraphQLCompositeType: [String: GraphQLField]] = [:]

    func collectFields(from selectionSet: CompilationResult.SelectionSet) {
      guard let type = selectionSet.parentType as? GraphQLInterfaceImplementingType else { return }
      for case let .field(field) in selectionSet.selections {
        add(field: field, to: type)
      }
    }

    func add<T: Sequence>(
      fields: T,
      to type: GraphQLInterfaceImplementingType
    ) where T.Element == CompilationResult.Field {
      for field in fields {
        add(field: field, to: type)
      }
    }

    func add(
      field: CompilationResult.Field,
      to type: GraphQLInterfaceImplementingType
    ) {
      var fields = collectedFields[type] ?? [:]
      guard let fieldOnType = type.fields[field.name] else {
        preconditionFailure("Cannot find field named '\(field.name)' on type '\(type.name)'.")
      }
      add(fieldOnType, to: &fields)
      collectedFields.updateValue(fields, forKey: type)
    }

    private func add(
      _ field: GraphQLField,
      to referencedFields: inout [String: GraphQLField]
    ) {
      let key = field.responseKey
      if !referencedFields.keys.contains(key) {
        referencedFields[key] = field
      }
    }

    func collectedFields(
      for type: GraphQLInterfaceImplementingType
    ) -> [(String, GraphQLField)] {
      var fields = collectedFields[type] ?? [:]

      for interface in type.interfaces {
        if let interfaceFields = collectedFields[interface] {
          fields.merge(interfaceFields) { field, _ in field }
        }
      }

      return fields.sorted { $0.0 < $1.0 }
    }
  }

}
