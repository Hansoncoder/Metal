//
//  Node.swift
//  MetalDemo
//
//  Created by Hanson on 16/6/3.
//  Copyright © 2016年 Hanson. All rights reserved.
//

import Foundation
import Metal
import QuartzCore

class Node {
    
    var name: String
    var vertexCount: Int
    var vertexBuffer: MTLBuffer
    var uniformBuffer: MTLBuffer
    var device: MTLDevice
    
    // 平移
    var positionX:Float = 0.0
    var positionY:Float = 0.0
    var positionZ:Float = 0.0
    // 旋转
    var rotationX:Float = 0.0
    var rotationY:Float = 0.0
    var rotationZ:Float = 0.0
    // 缩放
    var scale:Float     = 1.0
    
    init(name: String, vertices: Array<Vertex>, device: MTLDevice) {
        // 1. 将顶点数组 转为 float数组
        var vertexData = Array<Float>()
        for vertex in vertices{
            vertexData += vertex.floatBuffer()
        }

        // 2.根据顶点数据创建缓冲区
        let dataSize = vertexData.count * sizeofValue(vertexData[0])
        vertexBuffer = device.newBufferWithBytes(vertexData, length: dataSize, options: MTLResourceOptions.OptionCPUCacheModeDefault)
        uniformBuffer = device.newBufferWithLength(sizeof(Float) * 16 * 2, options: MTLResourceOptions.OptionCPUCacheModeDefault)
        
        // 3.给属性赋值
        self.name = name
        self.device = device
        vertexCount = vertices.count
        
    }
    
    /**
     渲染
     
     - parameter commandQueue:          命令队列
     - parameter pipelineState:         线管状态
     - parameter drawable:              画板（显示图层面板）
     - parameter parentModelViewMatrix: 普通模型视图
     - parameter projectionMatrix:      透视图
     - parameter clearColor:            背景颜色
     */
    func render(commandQueue: MTLCommandQueue, pipelineState: MTLRenderPipelineState, drawable: CAMetalDrawable, parentModelViewMatrix: Matrix4, projectionMatrix: Matrix4, clearColor: MTLClearColor?) {
        
        
        // 2.1 创建一个Render Pass Descriptor
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .Clear
        if let clearColor = clearColor {
            renderPassDescriptor.colorAttachments[0].clearColor = clearColor
        } else {
           renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
        }
        renderPassDescriptor.colorAttachments[0].storeAction = .Store
        
        // 2.2 创建一个Command Buffer
        let commandBuffer = commandQueue.commandBuffer()
        
        // 2.3 创建一个Render Command Encoder
        let renderEncoder = commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor)
        renderEncoder.setCullMode(MTLCullMode.Front)
        renderEncoder.setRenderPipelineState(pipelineState)
        // 2.3.0 添加数据缓冲区
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, atIndex: 0)
        // 2.3.1 添加变换缓冲区
        var nodeModelMatrix = modelMatrix()
        nodeModelMatrix = parentModelViewMatrix * nodeModelMatrix
        let bufferPointer = uniformBuffer.contents()
        memcpy(bufferPointer, nodeModelMatrix.matrix, Int(sizeof(Float) * 16))
        memcpy(bufferPointer + sizeof(Float) * 16, projectionMatrix.matrix, sizeof(Float) * 16)
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, atIndex: 1)
        // 2.3.2 绘制顶点数据
        renderEncoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: vertexCount, instanceCount: vertexCount / 3)
        renderEncoder.endEncoding()
        
        // 2.4 提交你Command Buffer的内容
        commandBuffer.presentDrawable(drawable)
        commandBuffer.commit()
        
    }
    
    func modelMatrix() -> Matrix4 {
        // 创建平移基数
        let translationMatrix = Matrix4.translationMatrix(x: positionX, y: positionY, z: positionZ)
        // 创建旋转基数
        let rotationMatrix = Matrix4.rotateAround(xAngleRad: rotationX, yAngleRad: rotationY, zAngleRad: rotationZ)
        // 创建缩放基数
        let scaleMatrix = Matrix4.scale(sx: scale,sy: scale,sz: scale)
        // 返回三个基数叠加效果
        return translationMatrix * rotationMatrix * scaleMatrix
    }
    
}