import Foundation
import Combine

// MARK: - Configurator View Model
class ConfiguratorViewModel: ObservableObject {
    @Published var currentStep: Int = 0
    @Published var configurationSteps: [ConfigurationStep] = []
    @Published var selectedComponents: [Component] = []
    @Published var availableComponents: [Component] = []
    @Published var configuration: ProductConfiguration
    @Published var billOfMaterials: BillOfMaterials?
    @Published var priceCalculation: PriceCalculationResult?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    private let productService: ProductService
    private let pricingService: PricingService
    private var cancellables = Set<AnyCancellable>()

    init(productService: ProductService = ProductService(),
         pricingService: PricingService = PricingService()) {
        self.productService = productService
        self.pricingService = pricingService
        self.configuration = ProductConfiguration(name: "New Configuration")

        setupConfigurationSteps()
        loadAvailableComponents()
    }

    // MARK: - Setup
    private func setupConfigurationSteps() {
        configurationSteps = [
            ConfigurationStep(
                stepNumber: 1,
                category: .base,
                title: "Select Base Component",
                description: "Choose the foundation for your industrial assembly"
            ),
            ConfigurationStep(
                stepNumber: 2,
                category: .motor,
                title: "Select Motor",
                description: "Choose a compatible motor for your application"
            ),
            ConfigurationStep(
                stepNumber: 3,
                category: .housing,
                title: "Select Housing",
                description: "Select protective housing for your assembly"
            ),
            ConfigurationStep(
                stepNumber: 4,
                category: .connector,
                title: "Select Connector",
                description: "Choose electrical connectors"
            ),
            ConfigurationStep(
                stepNumber: 5,
                category: .control,
                title: "Select Control Unit",
                description: "Select control system"
            ),
            ConfigurationStep(
                stepNumber: 6,
                category: .sensor,
                title: "Add Sensors (Optional)",
                description: "Add monitoring sensors"
            ),
            ConfigurationStep(
                stepNumber: 7,
                category: .accessory,
                title: "Add Accessories (Optional)",
                description: "Add mounting and cable management accessories"
            )
        ]
    }

    func loadAvailableComponents() {
        isLoading = true
        let currentCategory = configurationSteps[currentStep].category
        availableComponents = productService.getComponents(
            for: currentCategory,
            compatibleWith: selectedComponents
        )
        isLoading = false
    }

    // MARK: - Navigation
    func nextStep() {
        guard currentStep < configurationSteps.count - 1 else {
            return
        }

        configurationSteps[currentStep].isCompleted = true
        currentStep += 1
        loadAvailableComponents()
    }

    func previousStep() {
        guard currentStep > 0 else {
            return
        }

        currentStep -= 1
        loadAvailableComponents()
    }

    func canProceedToNextStep() -> Bool {
        let step = configurationSteps[currentStep]

        // Optional steps (sensors and accessories) can be skipped
        if step.category == .sensor || step.category == .accessory {
            return true
        }

        return step.selectedComponent != nil
    }

    // MARK: - Component Selection
    func selectComponent(_ component: Component) {
        let currentCategory = configurationSteps[currentStep].category

        // Remove any previously selected component from this category
        selectedComponents.removeAll { $0.category == currentCategory }

        // Add new selection
        selectedComponents.append(component)
        configurationSteps[currentStep].selectedComponent = component

        // Update configuration
        configuration.selectedComponents = selectedComponents
        configuration.lastModifiedDate = Date()

        // Recalculate price
        calculatePrice()
    }

    func deselectComponent(in category: ComponentCategory) {
        selectedComponents.removeAll { $0.category == category }

        if let stepIndex = configurationSteps.firstIndex(where: { $0.category == category }) {
            configurationSteps[stepIndex].selectedComponent = nil
            configurationSteps[stepIndex].isCompleted = false
        }

        configuration.selectedComponents = selectedComponents
        calculatePrice()
    }

    // MARK: - Price Calculation
    func calculatePrice() {
        guard !selectedComponents.isEmpty else {
            priceCalculation = nil
            billOfMaterials = nil
            return
        }

        priceCalculation = pricingService.calculatePrice(for: selectedComponents)
        billOfMaterials = pricingService.generateBOM(from: configuration)
    }

    // MARK: - Quote Generation
    func generateQuote(customerInfo: CustomerInfo, notes: String? = nil) -> Quote {
        return pricingService.generateQuote(
            from: configuration,
            customerInfo: customerInfo,
            notes: notes
        )
    }

    // MARK: - Reset
    func resetConfiguration() {
        currentStep = 0
        selectedComponents.removeAll()
        configuration = ProductConfiguration(name: "New Configuration")
        billOfMaterials = nil
        priceCalculation = nil

        for index in configurationSteps.indices {
            configurationSteps[index].selectedComponent = nil
            configurationSteps[index].isCompleted = false
        }

        loadAvailableComponents()
    }

    // MARK: - Validation
    func validateConfiguration() -> [String] {
        var errors: [String] = []

        // Check required components
        let requiredCategories: [ComponentCategory] = [.base, .motor, .housing, .connector, .control]

        for category in requiredCategories {
            if !selectedComponents.contains(where: { $0.category == category }) {
                errors.append("\(category.displayName) is required")
            }
        }

        return errors
    }

    func isConfigurationComplete() -> Bool {
        return validateConfiguration().isEmpty
    }
}
