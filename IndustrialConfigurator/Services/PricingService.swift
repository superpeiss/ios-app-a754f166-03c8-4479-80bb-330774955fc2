import Foundation

// MARK: - Pricing Service
class PricingService {
    private var pricingRules: [PricingRule] = []
    private let taxRate: Decimal = 0.08 // 8% tax rate

    init() {
        loadPricingRules()
    }

    // MARK: - Price Calculation
    func calculatePrice(for components: [Component]) -> PriceCalculationResult {
        var appliedRules: [PricingRule] = []
        var discounts: [String: Decimal] = [:]

        let subtotal = components.reduce(Decimal(0)) { $0 + $1.basePrice }

        // Apply volume discount
        if subtotal > 5000 {
            if let volumeRule = pricingRules.first(where: { $0.ruleType == .volumeDiscount && ($0.threshold ?? 0) <= subtotal }) {
                let discount = subtotal * (volumeRule.discountPercentage ?? 0)
                discounts["Volume Discount"] = discount
                appliedRules.append(volumeRule)
            }
        }

        // Apply bundle discounts
        if hasCompleteSystem(components) {
            if let bundleRule = pricingRules.first(where: { $0.ruleType == .bundleDiscount }) {
                let discount = subtotal * (bundleRule.discountPercentage ?? 0)
                discounts["Complete System Bundle"] = discount
                appliedRules.append(bundleRule)
            }
        }

        // Apply category discounts
        for category in ComponentCategory.allCases {
            let categoryComponents = components.filter { $0.category == category }
            if categoryComponents.count >= 2 {
                if let categoryRule = pricingRules.first(where: {
                    $0.ruleType == .categoryDiscount &&
                    $0.applicableComponentCategories?.contains(category) ?? false
                }) {
                    let categoryTotal = categoryComponents.reduce(Decimal(0)) { $0 + $1.basePrice }
                    let discount = categoryTotal * (categoryRule.discountPercentage ?? 0)
                    discounts["\(category.displayName) Discount"] = discount
                    appliedRules.append(categoryRule)
                }
            }
        }

        let totalDiscount = discounts.values.reduce(Decimal(0), +)
        let discountedSubtotal = subtotal - totalDiscount
        let taxAmount = discountedSubtotal * taxRate
        let total = discountedSubtotal + taxAmount

        return PriceCalculationResult(
            subtotal: subtotal,
            discounts: discounts,
            taxAmount: taxAmount,
            total: total,
            appliedRules: appliedRules
        )
    }

    // MARK: - BOM Generation
    func generateBOM(from configuration: ProductConfiguration) -> BillOfMaterials {
        var lineItems: [BOMLineItem] = []

        for component in configuration.selectedComponents {
            let lineItem = BOMLineItem(component: component, quantity: 1)
            lineItems.append(lineItem)
        }

        var bom = BillOfMaterials(
            configurationId: configuration.id,
            lineItems: lineItems,
            taxRate: taxRate
        )

        // Apply pricing rules and recalculate
        let priceResult = calculatePrice(for: configuration.selectedComponents)

        // Update BOM with calculated values
        bom.subtotal = priceResult.subtotal - priceResult.totalDiscount
        bom.tax = priceResult.taxAmount
        bom.total = priceResult.total

        return bom
    }

    // MARK: - Helper Methods
    private func hasCompleteSystem(_ components: [Component]) -> Bool {
        let categories = Set(components.map { $0.category })
        return categories.contains(.base) &&
               categories.contains(.motor) &&
               categories.contains(.housing) &&
               categories.contains(.control)
    }

    private func loadPricingRules() {
        pricingRules = [
            PricingRule(
                id: "PRICE-001",
                name: "Volume Discount 10%",
                ruleType: .volumeDiscount,
                threshold: 5000.00,
                discountPercentage: 0.10,
                discountAmount: nil,
                applicableComponentCategories: nil
            ),
            PricingRule(
                id: "PRICE-002",
                name: "Volume Discount 15%",
                ruleType: .volumeDiscount,
                threshold: 10000.00,
                discountPercentage: 0.15,
                discountAmount: nil,
                applicableComponentCategories: nil
            ),
            PricingRule(
                id: "PRICE-003",
                name: "Complete System Bundle",
                ruleType: .bundleDiscount,
                threshold: nil,
                discountPercentage: 0.05,
                discountAmount: nil,
                applicableComponentCategories: nil
            ),
            PricingRule(
                id: "PRICE-004",
                name: "Sensor Category Discount",
                ruleType: .categoryDiscount,
                threshold: nil,
                discountPercentage: 0.08,
                discountAmount: nil,
                applicableComponentCategories: [.sensor]
            )
        ]
    }

    // MARK: - Quote Generation
    func generateQuote(
        from configuration: ProductConfiguration,
        customerInfo: CustomerInfo,
        notes: String? = nil
    ) -> Quote {
        let bom = generateBOM(from: configuration)

        return Quote(
            configuration: configuration,
            billOfMaterials: bom,
            customerInfo: customerInfo,
            notes: notes
        )
    }
}
