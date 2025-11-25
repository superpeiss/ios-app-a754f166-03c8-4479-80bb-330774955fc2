import SwiftUI

// MARK: - Configurator Main View
struct ConfiguratorMainView: View {
    @StateObject private var viewModel = ConfiguratorViewModel()
    @EnvironmentObject var userSession: UserSession
    @State private var showingSaveSheet = false
    @State private var showingQuoteSheet = false
    @State private var configurationName = ""

    var body: some View {
        VStack(spacing: 0) {
            // Progress Bar
            ProgressView(value: Double(viewModel.currentStep + 1),
                        total: Double(viewModel.configurationSteps.count))
                .padding()

            // Step Indicator
            StepIndicatorView(
                currentStep: viewModel.currentStep,
                totalSteps: viewModel.configurationSteps.count,
                steps: viewModel.configurationSteps
            )
            .padding(.horizontal)

            // Main Content
            TabView(selection: $viewModel.currentStep) {
                ForEach(Array(viewModel.configurationSteps.enumerated()), id: \.element.id) { index, step in
                    ComponentSelectionView(
                        step: step,
                        availableComponents: viewModel.availableComponents,
                        selectedComponent: viewModel.selectedComponents.first { $0.category == step.category },
                        onSelect: { component in
                            viewModel.selectComponent(component)
                        },
                        onDeselect: {
                            viewModel.deselectComponent(in: step.category)
                        }
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .onChange(of: viewModel.currentStep) { _ in
                // Reload components when step changes
                viewModel.loadAvailableComponents()
            }

            // 3D Preview (Compact)
            if !viewModel.selectedComponents.isEmpty {
                VStack(spacing: 8) {
                    HStack {
                        Text("3D Preview")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }

                    ProductPreview3DView(selectedComponents: viewModel.selectedComponents)
                        .frame(height: 200)
                }
                .padding(.horizontal)
            }

            // Price Summary
            if let priceCalc = viewModel.priceCalculation {
                PriceSummaryView(priceCalculation: priceCalc)
                    .padding()
            }

            // Navigation Buttons
            HStack(spacing: 16) {
                if viewModel.currentStep > 0 {
                    Button(action: {
                        viewModel.previousStep()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Previous")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                    }
                }

                if viewModel.currentStep < viewModel.configurationSteps.count - 1 {
                    Button(action: {
                        viewModel.nextStep()
                    }) {
                        HStack {
                            Text("Next")
                            Image(systemName: "chevron.right")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.canProceedToNextStep() ? Color.blue : Color.gray.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(!viewModel.canProceedToNextStep())
                } else {
                    Button(action: {
                        showingQuoteSheet = true
                    }) {
                        HStack {
                            Image(systemName: "doc.text.fill")
                            Text("Generate Quote")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isConfigurationComplete() ? Color.green : Color.gray.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(!viewModel.isConfigurationComplete())
                }
            }
            .padding()
        }
        .navigationTitle("Configure Product")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showingSaveSheet = true }) {
                        Label("Save Configuration", systemImage: "square.and.arrow.down")
                    }
                    .disabled(viewModel.selectedComponents.isEmpty)

                    Button(action: { viewModel.resetConfiguration() }) {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingSaveSheet) {
            SaveConfigurationSheet(
                configurationName: $configurationName,
                isPresented: $showingSaveSheet,
                onSave: {
                    var config = viewModel.configuration
                    config.name = configurationName.isEmpty ? "Configuration \(Date().formatted(date: .abbreviated, time: .omitted))" : configurationName
                    userSession.saveConfiguration(config)
                    configurationName = ""
                }
            )
        }
        .sheet(isPresented: $showingQuoteSheet) {
            QuoteGenerationView(
                viewModel: viewModel,
                isPresented: $showingQuoteSheet
            )
            .environmentObject(userSession)
        }
    }
}

// MARK: - Step Indicator View
struct StepIndicatorView: View {
    let currentStep: Int
    let totalSteps: Int
    let steps: [ConfigurationStep]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Step \(currentStep + 1) of \(totalSteps)")
                .font(.caption)
                .foregroundColor(.secondary)

            if steps.indices.contains(currentStep) {
                Text(steps[currentStep].title)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(steps[currentStep].description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Component Selection View
struct ComponentSelectionView: View {
    let step: ConfigurationStep
    let availableComponents: [Component]
    let selectedComponent: Component?
    let onSelect: (Component) -> Void
    let onDeselect: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if availableComponents.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)

                        Text("No Compatible Components")
                            .font(.headline)

                        Text("The previously selected components have limited compatibility options. Try going back and selecting different components.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                } else {
                    ForEach(availableComponents) { component in
                        ComponentCard(
                            component: component,
                            isSelected: selectedComponent?.id == component.id,
                            onTap: {
                                if selectedComponent?.id == component.id {
                                    onDeselect()
                                } else {
                                    onSelect(component)
                                }
                            }
                        )
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Component Card
struct ComponentCard: View {
    let component: Component
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(component.name)
                            .font(.headline)
                            .foregroundColor(.primary)

                        Text(component.category.displayName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                    }
                }

                Text(component.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                // Specifications
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(component.specifications.prefix(3)), id: \.key) { key, value in
                        HStack {
                            Text(key)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(value)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                    }
                }
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)

                // Price
                HStack {
                    Text("Price:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(formatPrice(component.basePrice))
                        .font(.headline)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color(UIColor.systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            )
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func formatPrice(_ price: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: price as NSDecimalNumber) ?? "$0.00"
    }
}

// MARK: - Price Summary View
struct PriceSummaryView: View {
    let priceCalculation: PriceCalculationResult

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Subtotal")
                    .font(.subheadline)
                Spacer()
                Text(formatPrice(priceCalculation.subtotal))
                    .font(.subheadline)
            }

            ForEach(Array(priceCalculation.discounts.keys.sorted()), id: \.self) { key in
                if let discount = priceCalculation.discounts[key] {
                    HStack {
                        Text(key)
                            .font(.caption)
                            .foregroundColor(.green)
                        Spacer()
                        Text("-\(formatPrice(discount))")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }

            HStack {
                Text("Tax")
                    .font(.subheadline)
                Spacer()
                Text(formatPrice(priceCalculation.taxAmount))
                    .font(.subheadline)
            }

            Divider()

            HStack {
                Text("Total")
                    .font(.headline)
                Spacer()
                Text(formatPrice(priceCalculation.total))
                    .font(.headline)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }

    private func formatPrice(_ price: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: price as NSDecimalNumber) ?? "$0.00"
    }
}

// MARK: - Save Configuration Sheet
struct SaveConfigurationSheet: View {
    @Binding var configurationName: String
    @Binding var isPresented: Bool
    let onSave: () -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Configuration Name")) {
                    TextField("Enter name", text: $configurationName)
                }

                Section {
                    Button(action: {
                        onSave()
                        isPresented = false
                    }) {
                        HStack {
                            Spacer()
                            Text("Save")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Save Configuration")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
}
