import Foundation
import Combine

// MARK: - Product Service
class ProductService: ObservableObject {
    @Published var allComponents: [Component] = []
    @Published var compatibilityRules: [CompatibilityRule] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    init() {
        loadMockData()
    }

    // MARK: - Data Loading
    func loadComponents() {
        isLoading = true
        errorMessage = nil

        // Simulate API call with delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.loadMockData()
            self?.isLoading = false
        }
    }

    // MARK: - Component Queries
    func getComponents(for category: ComponentCategory, compatibleWith selectedComponents: [Component]) -> [Component] {
        let categoryComponents = allComponents.filter { $0.category == category && $0.isAvailable }

        if selectedComponents.isEmpty {
            return categoryComponents
        }

        return categoryComponents.filter { component in
            isComponentCompatible(component, with: selectedComponents)
        }
    }

    func getComponent(by id: String) -> Component? {
        return allComponents.first { $0.id == id }
    }

    // MARK: - Compatibility Check
    func isComponentCompatible(_ component: Component, with selectedComponents: [Component]) -> Bool {
        guard let rule = compatibilityRules.first(where: { $0.componentId == component.id }) else {
            return true // No rules means compatible with everything
        }

        for selected in selectedComponents {
            // Check if explicitly incompatible
            if let incompatibleIds = rule.incompatibleWithIds,
               incompatibleIds.contains(selected.id) {
                return false
            }

            // Check if in compatible list
            if !rule.compatibleWithIds.isEmpty &&
               !rule.compatibleWithIds.contains(selected.id) {
                return false
            }
        }

        // Check required components
        if let requiredIds = rule.requiresComponentIds {
            let selectedIds = selectedComponents.map { $0.id }
            for requiredId in requiredIds {
                if !selectedIds.contains(requiredId) {
                    return false
                }
            }
        }

        return true
    }

    // MARK: - Mock Data
    private func loadMockData() {
        // Base Components
        allComponents = [
            // Base Components
            Component(
                id: "BASE-001",
                name: "Industrial Base Unit A100",
                category: .base,
                description: "Heavy-duty base unit with mounting points",
                specifications: ["Dimensions": "500x400x100mm", "Weight": "25kg", "Material": "Cast Iron"],
                basePrice: 1250.00,
                modelIdentifier: "base_a100"
            ),
            Component(
                id: "BASE-002",
                name: "Compact Base Unit B50",
                category: .base,
                description: "Compact base for smaller installations",
                specifications: ["Dimensions": "300x250x80mm", "Weight": "12kg", "Material": "Aluminum"],
                basePrice: 850.00,
                modelIdentifier: "base_b50"
            ),

            // Motors
            Component(
                id: "MOTOR-001",
                name: "High-Torque Motor 5.5kW",
                category: .motor,
                description: "Industrial 3-phase motor, 5.5kW",
                specifications: ["Power": "5.5kW", "Voltage": "380V", "RPM": "1450"],
                basePrice: 2450.00,
                modelIdentifier: "motor_5_5kw"
            ),
            Component(
                id: "MOTOR-002",
                name: "Standard Motor 2.2kW",
                category: .motor,
                description: "Compact 3-phase motor, 2.2kW",
                specifications: ["Power": "2.2kW", "Voltage": "220V", "RPM": "1400"],
                basePrice: 1200.00,
                modelIdentifier: "motor_2_2kw"
            ),

            // Housings
            Component(
                id: "HOUSING-001",
                name: "IP65 Protective Housing",
                category: .housing,
                description: "Dustproof and water-resistant enclosure",
                specifications: ["Rating": "IP65", "Material": "Stainless Steel"],
                basePrice: 680.00,
                modelIdentifier: "housing_ip65"
            ),
            Component(
                id: "HOUSING-002",
                name: "Standard Housing IP54",
                category: .housing,
                description: "Standard protective enclosure",
                specifications: ["Rating": "IP54", "Material": "Powder-coated Steel"],
                basePrice: 420.00,
                modelIdentifier: "housing_ip54"
            ),

            // Connectors
            Component(
                id: "CONN-001",
                name: "Heavy-Duty Connector Set",
                category: .connector,
                description: "High-current connector assembly",
                specifications: ["Current": "63A", "Poles": "5", "Type": "Industrial"],
                basePrice: 180.00,
                modelIdentifier: "connector_heavy"
            ),
            Component(
                id: "CONN-002",
                name: "Standard Connector Set",
                category: .connector,
                description: "Standard connector assembly",
                specifications: ["Current": "32A", "Poles": "4", "Type": "Standard"],
                basePrice: 95.00,
                modelIdentifier: "connector_std"
            ),

            // Control Units
            Component(
                id: "CTRL-001",
                name: "Advanced PLC Controller",
                category: .control,
                description: "Programmable logic controller with touchscreen",
                specifications: ["I/O Points": "32", "Display": "7\" Touch", "Memory": "512KB"],
                basePrice: 3200.00,
                modelIdentifier: "control_plc"
            ),
            Component(
                id: "CTRL-002",
                name: "Basic Control Panel",
                category: .control,
                description: "Simple control panel with manual controls",
                specifications: ["Buttons": "6", "Display": "LED", "Memory": "N/A"],
                basePrice: 450.00,
                modelIdentifier: "control_basic"
            ),

            // Sensors
            Component(
                id: "SENS-001",
                name: "Temperature Sensor Module",
                category: .sensor,
                description: "Industrial temperature monitoring",
                specifications: ["Range": "-40°C to 200°C", "Accuracy": "±0.5°C", "Output": "4-20mA"],
                basePrice: 220.00,
                modelIdentifier: "sensor_temp"
            ),
            Component(
                id: "SENS-002",
                name: "Vibration Sensor",
                category: .sensor,
                description: "Vibration and shock detection",
                specifications: ["Range": "0-50g", "Frequency": "1-10kHz", "Output": "Digital"],
                basePrice: 340.00,
                modelIdentifier: "sensor_vib"
            ),

            // Accessories
            Component(
                id: "ACC-001",
                name: "Mounting Kit Premium",
                category: .accessory,
                description: "Complete mounting hardware set",
                specifications: ["Contents": "Bolts, Brackets, Anchors", "Material": "Stainless Steel"],
                basePrice: 125.00,
                modelIdentifier: "accessory_mount"
            ),
            Component(
                id: "ACC-002",
                name: "Cable Management Kit",
                category: .accessory,
                description: "Cable trays and tie-downs",
                specifications: ["Length": "5m", "Width": "100mm", "Material": "PVC"],
                basePrice: 85.00,
                modelIdentifier: "accessory_cable"
            )
        ]

        // Compatibility Rules
        compatibilityRules = [
            // Base A100 compatibility
            CompatibilityRule(
                id: "RULE-001",
                componentId: "MOTOR-001",
                compatibleWithIds: ["BASE-001"],
                incompatibleWithIds: ["BASE-002"]
            ),
            CompatibilityRule(
                id: "RULE-002",
                componentId: "MOTOR-002",
                compatibleWithIds: ["BASE-001", "BASE-002"]
            ),

            // Housing compatibility
            CompatibilityRule(
                id: "RULE-003",
                componentId: "HOUSING-001",
                compatibleWithIds: ["MOTOR-001", "MOTOR-002"]
            ),
            CompatibilityRule(
                id: "RULE-004",
                componentId: "HOUSING-002",
                compatibleWithIds: ["MOTOR-002"],
                incompatibleWithIds: ["MOTOR-001"]
            ),

            // Connector compatibility
            CompatibilityRule(
                id: "RULE-005",
                componentId: "CONN-001",
                compatibleWithIds: ["MOTOR-001", "CTRL-001"]
            ),
            CompatibilityRule(
                id: "RULE-006",
                componentId: "CONN-002",
                compatibleWithIds: ["MOTOR-002", "CTRL-002"]
            ),

            // Control unit compatibility
            CompatibilityRule(
                id: "RULE-007",
                componentId: "CTRL-001",
                compatibleWithIds: ["MOTOR-001", "MOTOR-002"]
            ),
            CompatibilityRule(
                id: "RULE-008",
                componentId: "CTRL-002",
                compatibleWithIds: ["MOTOR-002"],
                incompatibleWithIds: ["MOTOR-001"]
            )
        ]
    }
}
