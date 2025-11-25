# Industrial Configurator iOS App

A production-ready iOS application for configuring highly customizable industrial components with real-time compatibility checking, 3D preview, and quote generation.

## Features

- **Multi-Step Configuration Process**: Guided workflow through selecting base components, motors, housing, connectors, controls, sensors, and accessories
- **Dynamic Compatibility Checking**: Real-time filtering of compatible components based on previous selections
- **Live 3D Preview**: Interactive 3D visualization of the assembled product using SceneKit
- **Advanced Pricing Engine**: Complex pricing logic with volume discounts, bundle pricing, and category-based promotions
- **Bill of Materials Generation**: Automatic BOM creation with itemized pricing
- **Professional Quote Generation**: Formal quotes with customer information, terms, and validity periods
- **Quote Management**: Save and retrieve quotes with status tracking
- **Configuration Storage**: Save and load product configurations

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.9+

## Architecture

The app follows MVVM (Model-View-ViewModel) architecture with the following structure:

- **Models**: Data structures for Components, Configurations, BOMs, Quotes, and Users
- **Views**: SwiftUI views for the user interface
- **ViewModels**: Business logic and state management
- **Services**: Data and business logic services (ProductService, PricingService)

## Project Structure

```
IndustrialConfigurator/
├── Models/
│   ├── Component.swift
│   ├── BillOfMaterials.swift
│   ├── Quote.swift
│   └── UserSession.swift
├── Views/
│   ├── ContentView.swift
│   ├── ConfiguratorMainView.swift
│   ├── QuoteViews.swift
│   └── ProductPreview3DView.swift
├── ViewModels/
│   └── ConfiguratorViewModel.swift
├── Services/
│   ├── ProductService.swift
│   └── PricingService.swift
└── Resources/
    └── Assets.xcassets
```

## Building the Project

The project uses a standard Xcode project structure.

### Using Xcode

1. Open `IndustrialConfigurator.xcodeproj` in Xcode
2. Select the `IndustrialConfigurator` scheme
3. Choose your target device or simulator
4. Build and run (⌘+R)

### Using xcodebuild (CLI)

```bash
xcodebuild -project IndustrialConfigurator.xcodeproj \
  -scheme IndustrialConfigurator \
  -destination 'generic/platform=iOS' \
  clean build
```

## Key Components

### Component Selection
The configurator guides users through 7 steps:
1. Base Component
2. Motor
3. Housing
4. Connector
5. Control Unit
6. Sensors (Optional)
7. Accessories (Optional)

### Compatibility Rules
Components have predefined compatibility rules that dynamically filter available options based on previous selections.

### Pricing Engine
- Volume-based discounts (10% over $5,000, 15% over $10,000)
- Complete system bundle discount (5%)
- Category-specific discounts
- Automatic tax calculation (8%)

### 3D Visualization
Real-time 3D rendering using SceneKit with:
- Interactive camera controls
- Automatic component stacking
- Category-specific geometries and colors
- Professional lighting

## Data Persistence

- User sessions stored in UserDefaults
- Configurations and quotes saved locally
- Easy migration to cloud storage (Core Data, CloudKit, or backend API)

## License

Copyright © 2024 Industrial Configurator. All rights reserved.
