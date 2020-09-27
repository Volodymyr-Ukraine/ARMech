//
//  ViewController.swift
//  TextOnTheWall
//
//  Created by Vladimir on 26.09.2020.
//  Copyright © 2020 Volodymyr. All rights reserved.
//

import UIKit
import RealityKit
import ARKit

class ViewController: UIViewController {
    
    private let name = "OBJ_20091"
    
    @IBOutlet var arView: ARView!
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
////
////        // Load the "Box" scene from the "Experience" Reality File
////        let boxAnchor = try! Experience.loadBox()
////
////        // Add the box anchor to the scene
////        arView.scene.anchors.append(boxAnchor)
//
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupARView()
        
        arView.session.delegate = self
        
        arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:))))
    }
    
    // MARK: Private Methods
    
    private func setupARView(){
        arView.automaticallyConfigureSession = false
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.environmentTexturing = .automatic
        arView.session.run(configuration)
        
    }
     
    @objc private func handleTap(recognizer: UITapGestureRecognizer){
        let location = recognizer.location(in: arView)
        let result = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
        
        if let firstResult = result.first {
            let anchor = ARAnchor(name: name, transform: firstResult.worldTransform)
            arView.session.add(anchor: anchor)
        } else {
            let alert = UIAlertController(title: "Hey", message: "Surface not found", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            self.show(alert, sender: self)
        }
        
    }
    
    func placeObject(named entityName: String, for anchor: ARAnchor) {
        do {
        guard let entity = try? ModelEntity.loadModel(named: entityName) else {
            
            return
        }
            
            
        entity.generateCollisionShapes(recursive: true)
//            entity.children.forEach{
//                $0.setScale(SIMD3<Float>(0.1,0.1,0.1), relativeTo: entity)
//            }
//        entity.setScale(SIMD3<Float>(0.1,0.1,0.1), relativeTo: nil)
        
            
        arView.installGestures([.rotation, .translation], for: entity)
        
        let anchorEntity = AnchorEntity(anchor: anchor)
        anchorEntity.addChild(entity)
        arView.scene.addAnchor(anchorEntity)
            } catch {
                    print(error)
                    return
            }
    }
}

extension ViewController: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let anchorName = anchor.name,
                anchorName == name {
                placeObject(named: anchorName, for: anchor)
                
            }
        }
    }
    
    
}
