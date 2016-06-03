//
//  Vertex.swift
//  MetalDemo
//
//  Created by Hanson on 16/6/3.
//  Copyright © 2016年 Hanson. All rights reserved.
//

import Foundation

struct Vertex{
    
    var x,y,z,w: Float     // position data
    var r,g,b,a: Float   // color data
    
    func floatBuffer() -> [Float] {
        return [x,y,z,w,r,g,b,a]
    }
};