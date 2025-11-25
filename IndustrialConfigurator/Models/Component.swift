import Foundation

// MARK: - Component Category
enum ComponentCategory: String, Codable, CaseIterable {
    case base = "Base Component"
    case motor = "Motor"
    case housing = "Housing"
    case connector = "Connector"
    case control = "Control Unit"
    case sensor = "Sensor"
    case accessory = "Accessory"

    var displayName: String {
        return self.rawValue
    }
}

// MARK: - Component
struct Component: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let category: ComponentCategory
    let description: String
    let specifications: [String: String]
    let basePrice: Decimal
    let imageURL: String?
    let modelIdentifier: String // For 3D model
    var isAvailable: Bool

    init(id: String, name: String, category: ComponentCategory, description: String,
         specifications: [String: String], basePrice: Decimal,
         imageURL: String? = nil, modelIdentifier: String, isAvailable: Bool = true) {
        self.id = id
        self.name = name
        self.category = category
        self.description = description
        self.specifications = specifications
        self.basePrice = basePrice
        self.imageURL = imageURL
        self.modelIdentifier = modelIdentifier
        self.isAvailable = isAvailable
    }
}

// MARK: - Compatibility Rule
struct CompatibilityRule: Codable, Identifiable {
    let id: String
    let componentId: String
    let compatibleWithIds: [String]
    let requiresComponentIds: [String]?
    let incompatibleWithIds: [String]?
    let conditions: [String: String]? // Additional compatibility conditions

    init(id: String, componentId: String, compatibleWithIds: [String],
         requiresComponentIds: [String]? = nil,
         incompatibleWithIds: [String]? = nil,
         conditions: [String: String]? = nil) {
        self.id = id
        self.componentId = componentId
        self.compatibleWithIds = compatibleWithIds
        self.requiresComponentIds = requiresComponentIds
        self.incompatibleWithIds = incompatibleWithIds
        self.conditions = conditions
    }
}

// MARK: - Configuration Step
struct ConfigurationStep: Identifiable {
    let id: UUID
    let stepNumber: Int
    let category: ComponentCategory
    let title: String
    let description: String
    var isCompleted: Bool
    var selectedComponent: Component?

    init(stepNumber: Int, category: ComponentCategory, title: String, description: String) {
        self.id = UUID()
        self.stepNumber = stepNumber
        self.category = category
        self.title = title
        self.description = description
        self.isCompleted = false
        self.selectedComponent = nil
    }
}

// MARK: - Product Configuration
struct ProductConfiguration: Identifiable, Codable {
    let id: String
    var name: String
    var selectedComponents: [Component]
    var createdDate: Date
    var lastModifiedDate: Date

    init(id: String = UUID().uuidString, name: String,
         selectedComponents: [Component] = [],
         createdDate: Date = Date(),
         lastModifiedDate: Date = Date()) {
        self.id = id
        self.name = name
        self.selectedComponents = selectedComponents
        self.createdDate = createdDate
        self.lastModifiedDate = lastModifiedDate
    }
}
