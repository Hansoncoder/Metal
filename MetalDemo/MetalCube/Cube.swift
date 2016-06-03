//
//  Cube.swift
//  MetalDemo
//
//  Created by Hanson on 16/6/3.
//  Copyright © 2016年 Hanson. All rights reserved.
//

import Foundation
import Metal

class Cube: Node {
    init(device: MTLDevice) {
        // 顶点数据
        let vertexA = Vertex(x: -0.5, y: 0.5, z: 0.5, w: 1.0, r: 1.0, g: 0.0, b: 0.0, a: 1.0)
        let vertexB = Vertex(x: -0.5, y: -0.5, z: 0.5, w: 1.0, r: 0.0, g: 1.0, b: 0.0, a: 1.0)
        let vertexC = Vertex(x: 0.5, y: -0.5, z: 0.5, w: 1.0, r: 0.0, g: 0.0, b: 1.0, a: 1.0)
        let vertexD = Vertex(x: 0.5, y: 0.5, z: 0.5, w: 1.0, r: 0.1, g: 0.6, b: 0.4, a: 1.0)
        let vertexQ = Vertex(x: -0.5, y: 0.5, z: -0.5, w: 1.0, r: 0.2, g: 0.3, b: 0.5, a: 1.0)
        let vertexR = Vertex(x: 0.5, y: 0.5, z: -0.5, w: 1.0, r: 0.4, g: 0.2, b: 0.3, a: 1.0)
        let vertexS = Vertex(x: -0.5, y: -0.5, z: -0.5, w: 1.0, r: 0.6, g: 0.1, b: 0.7, a: 1.0)
        let vertexT = Vertex(x: 0.5, y: -0.5, z: -0.5, w: 1.0, r: 0.4, g: 0.8, b: 1.0, a: 1.0)
        
        let vertexArr = [vertexA, vertexB, vertexC, vertexD, vertexA, vertexC,
                         vertexA, vertexB, vertexS, vertexA, vertexQ, vertexS,
                         vertexA, vertexD, vertexR, vertexA, vertexQ, vertexR,
                         vertexC, vertexD, vertexR, vertexC, vertexT, vertexR,
                         vertexB, vertexC, vertexT, vertexB, vertexS, vertexT,
                         vertexS, vertexT, vertexR, vertexS, vertexQ, vertexR]
        // 创建节点
        super.init(name: "Cube", vertices: vertexArr, device: device)
        
    }
}