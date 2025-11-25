import SwiftUI
import SceneKit

// MARK: - 3D Preview View
struct ProductPreview3DView: View {
    let selectedComponents: [Component]
    @State private var scene = SCNScene()
    @State private var cameraNode = SCNNode()

    var body: some View {
        VStack {
            SceneView(
                scene: scene,
                pointOfView: cameraNode,
                options: [.allowsCameraControl, .autoenablesDefaultLighting]
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(12)
            .onAppear {
                setupScene()
            }
            .onChange(of: selectedComponents) { _ in
                updateScene()
            }

            if selectedComponents.isEmpty {
                Text("Select components to see 3D preview")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
    }

    private func setupScene() {
        // Create camera
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 5, z: 15)
        cameraNode.look(at: SCNVector3(x: 0, y: 0, z: 0))
        scene.rootNode.addChildNode(cameraNode)

        // Add ambient light
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.color = UIColor(white: 0.6, alpha: 1.0)
        scene.rootNode.addChildNode(ambientLight)

        // Add directional light
        let directionalLight = SCNNode()
        directionalLight.light = SCNLight()
        directionalLight.light?.type = .directional
        directionalLight.light?.color = UIColor.white
        directionalLight.position = SCNVector3(x: 5, y: 10, z: 5)
        directionalLight.look(at: SCNVector3(x: 0, y: 0, z: 0))
        scene.rootNode.addChildNode(directionalLight)

        updateScene()
    }

    private func updateScene() {
        // Remove all existing component nodes
        scene.rootNode.childNodes.forEach { node in
            if node.name?.starts(with: "component_") == true {
                node.removeFromParentNode()
            }
        }

        var yOffset: Float = 0

        for (index, component) in selectedComponents.enumerated() {
            let componentNode = createComponentNode(for: component)
            componentNode.name = "component_\(index)"
            componentNode.position = SCNVector3(x: 0, y: yOffset, z: 0)
            scene.rootNode.addChildNode(componentNode)

            // Stack components vertically
            yOffset += getComponentHeight(for: component.category)
        }
    }

    private func createComponentNode(for component: Component) -> SCNNode {
        let node = SCNNode()

        // Create geometry based on component category
        let geometry: SCNGeometry
        let material = SCNMaterial()

        switch component.category {
        case .base:
            geometry = SCNBox(width: 3, height: 0.5, length: 2, chamferRadius: 0.1)
            material.diffuse.contents = UIColor.systemGray

        case .motor:
            geometry = SCNCylinder(radius: 0.8, height: 1.5)
            material.diffuse.contents = UIColor.systemBlue

        case .housing:
            geometry = SCNBox(width: 2.5, height: 2, length: 2, chamferRadius: 0.2)
            material.diffuse.contents = UIColor.systemGreen
            material.transparency = 0.7

        case .connector:
            geometry = SCNBox(width: 0.3, height: 0.3, length: 0.8, chamferRadius: 0.05)
            material.diffuse.contents = UIColor.systemOrange

        case .control:
            geometry = SCNBox(width: 1.2, height: 0.8, length: 0.4, chamferRadius: 0.1)
            material.diffuse.contents = UIColor.systemIndigo

        case .sensor:
            geometry = SCNSphere(radius: 0.2)
            material.diffuse.contents = UIColor.systemRed

        case .accessory:
            geometry = SCNBox(width: 0.5, height: 0.2, length: 0.5, chamferRadius: 0.05)
            material.diffuse.contents = UIColor.systemYellow
        }

        material.specular.contents = UIColor.white
        material.shininess = 0.5
        geometry.materials = [material]
        node.geometry = geometry

        return node
    }

    private func getComponentHeight(for category: ComponentCategory) -> Float {
        switch category {
        case .base: return 0.6
        case .motor: return 1.6
        case .housing: return 2.1
        case .connector: return 0.4
        case .control: return 0.9
        case .sensor: return 0.3
        case .accessory: return 0.3
        }
    }
}

// MARK: - Preview
struct ProductPreview3DView_Previews: PreviewProvider {
    static var previews: some View {
        ProductPreview3DView(selectedComponents: [])
    }
}
