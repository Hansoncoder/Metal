//
//  Triangle.swift
//  MetalDemo
//
//  Created by Hanson on 16/6/3.
//  Copyright © 2016年 Hanson. All rights reserved.
//

import Foundation
import Metal

class Triangle: Node {
    init(device: MTLDevice) {
        // 顶点数据
        let vertexA = Vertex(x: 1.0, y: -1.0, z: 0.0, w: 1.0, r: 1.0, g: 0.0, b: 0.0, a: 1.0)
        let vertexB = Vertex(x: -1.0, y: -1.0, z: 0.0, w: 1.0, r: 0.0, g: 1.0, b: 0.0, a: 1.0)
        let verTexC = Vertex(x: 1.0, y: 1.0, z: 0.0, w: 1.0, r: 0.0, g: 0.0, b: 1.0, a: 1.0)
        let vertexArr = [vertexA, vertexB, verTexC]
        
        // 创建节点
        super.init(name: "Triangle", vertices: vertexArr, device: device)
        
    }
}