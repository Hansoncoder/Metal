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
        let A = Vertex(x: -1.0, y:  1.0, z:  1.0, w: 1.0, r: 1.0, g: 0.0, b: 0.0, a: 1.0)
        let B = Vertex(x: -1.0, y: -1.0, z:  1.0, w: 1.0, r: 0.5, g: 1.0, b: 0.5, a: 1.0)
        let C = Vertex(x:  1.0, y: -1.0, z:  1.0, w: 1.0, r: 0.0, g: 0.0, b: 1.0, a: 1.0)
        let D = Vertex(x:  1.0, y:  1.0, z:  1.0, w: 1.0, r: 0.0, g: 0.0, b: 0.0, a: 1.0)
        let Q = Vertex(x: -1.0, y:  1.0, z: -1.0, w: 1.0, r: 0.0, g: 1.0, b: 1.0, a: 1.0)
        let R = Vertex(x:  1.0, y:  1.0, z: -1.0, w: 1.0, r: 1.0, g: 1.0, b: 0.0, a: 1.0)
        let S = Vertex(x: -1.0, y: -1.0, z: -1.0, w: 1.0, r: 1.0, g: 0.0, b: 1.0, a: 1.0)
        let T = Vertex(x:  1.0, y: -1.0, z: -1.0, w: 1.0, r: 0.0, g: 0.0, b: 0.0, a: 1.0)
        
        let vertexArr = [A, B, C,  A, C, D, // 前面
                         R, T, S,  Q, R, S, // 后面
                         Q, S, B,  Q, B, A, // 左面
                         D, C, T,  D, T, R, // 右面
                         Q, A, D,  Q, D, R, // 上面
                         B, S, T,  B, T, C] // 下面
        // 创建节点
        super.init(name: "Cube", vertices: vertexArr, device: device)
        
    }
}