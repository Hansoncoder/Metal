//
//  ViewController.swift
//  MetalSquare
//
//  Created by Hanson on 16/6/2.
//  Copyright © 2016年 Hanson. All rights reserved.
//

import UIKit
import simd

// 旋转矩阵
struct Uniforms {
    var rotation_matrix: matrix_float4x4
}

class ViewController: UIViewController {
    
    // 设置metal
    var device: MTLDevice! = nil
    var metalLayer: CAMetalLayer! = nil
    var pipelineState: MTLRenderPipelineState! = nil
    var vertexBuffer: MTLBuffer! = nil
    var commandQueue: MTLCommandQueue! = nil
    // 渲染图形
    var timer: CADisplayLink! = nil
    
    // 用于旋转辅助变量
    var uniformBuffer: MTLBuffer! = nil // 旋转矩阵缓冲区
    var uniforms: Uniforms! // 旋转矩阵
    var rotationAngle: Float = 0.0 // 旋转角度
    
    // 数据源[x,y,z,w, r,g,b,a]
    //前四个数字代表了每一个顶点的 x，y，z 和 w 元素。后四个数字代表每个顶点的红色，绿色，蓝色和透明值元素。
    //第四个顶点位置元素，w，是一个数学上的便利，使我们能以一种统一的方式描述 3D 转换 (旋转，平移，缩放
    let vertexData: [Float]  = [
        0.5, -0.5, 0.0,1.0,      1.0, 0.0, 0.0, 1.0,
        -0.5, -0.5, 0.0, 1.0,      0.0, 1.0, 0.0, 1.0,
        -0.5, 0.5, 0.0, 1.0,      0.0, 0.0, 1.0, 1.0,
        0.5, 0.5, 0.0, 1.0,      1.0, 1.0, 0.0, 1.0,
        0.5, -0.5, 0.0, 1.0,      1.0, 0.0, 0.0, 1.0,
        -0.5, 0.5, 0.0, 1.0,      0.0, 0.0, 1.0, 1.0,
        ]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 初始化Metal
        setupMetal()
        // 渲染图形
        displayContent()
    }
    
    /************************** 七步设置Metal ****************************/
    // MARK: - 七步设置Metal
    
    private func setupMetal() {
        
        // 1.0 创建一个MTLDevice
        device = MTLCreateSystemDefaultDevice()
        
        // 1.1 创建一个CAMetalLayer
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .BGRA8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.layer.frame
        view.layer.addSublayer(metalLayer)
        
        // 1.2 创建一个Vertex Buffer
        let dataSize = vertexData.count * sizeofValue(vertexData[0])
        vertexBuffer = device.newBufferWithBytes(vertexData, length: dataSize, options: MTLResourceOptions.OptionCPUCacheModeDefault)
        // 旋转缓冲区内容时刻变化，这里通过长度创建
        uniformBuffer = device.newBufferWithLength(sizeof(Uniforms), options: MTLResourceOptions.OptionCPUCacheModeDefault)
        
        
        let defaultLibrary = device.newDefaultLibrary()
        // 1.3 创建一个Vertex Shader
        let vertexProgram = defaultLibrary?.newFunctionWithName("basic_vertex")
        // 1.4 创建一个Fragment Shader
        let fragmentProgram = defaultLibrary?.newFunctionWithName("basic_fragment")
        
        // 1.5 创建一个Render Pipeline
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .BGRA8Unorm
        pipelineState = try! device.newRenderPipelineStateWithDescriptor(pipelineStateDescriptor)
        
        // 1.6 创建一个Command Queue
        commandQueue = device.newCommandQueue()
    }
    
    
    /************************** 五步完成渲染 ****************************/
    // MARK: - 五步完成渲染
    
    private func displayContent() {
        
        // 2.0 创建一个Display link
        timer = CADisplayLink(target: self, selector: #selector(ViewController.gameloop))
        timer.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    }
    
    
    func render() {
        
        let drawable = metalLayer.nextDrawable()
        
        // 2.1 创建一个Render Pass Descriptor
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable?.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .Clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 104.0/255.0, blue: 5.0/255.0, alpha: 1.0)
        renderPassDescriptor.colorAttachments[0].storeAction = .Store
        
        // 2.2 创建一个Command Buffer
        let commandBuffer = commandQueue.commandBuffer()
        
        // 2.3 创建一个Render Command Encoder
        let renderEncoder = commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor)
        renderEncoder.setRenderPipelineState(pipelineState)
        // 将vertexBuffer添加到第0个缓冲区（等下metal着色器要取出值）
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, atIndex: 0)
        // 将uniformBuffer添加到第1个缓冲区（等下metal着色器要取出值）
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, atIndex: 1)
        renderEncoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: 6)
        renderEncoder.endEncoding()
        
        // 2.4 提交你Command Buffer的内容
        commandBuffer.presentDrawable(drawable!)
        commandBuffer.commit()
        
    }
    
    
    // MARK: - 其他
    
    // 循环执行
    func gameloop() {
        autoreleasepool {
            update()
            render()
        }
    }
    
    // 将图层改为正方形
    override func viewDidLayoutSubviews() {
        let parentSize = view.bounds.size
        let minSize = min(parentSize.width,parentSize.height)
        let frame = CGRectMake((parentSize.width - minSize) * 0.5,
                               (parentSize.height - minSize) * 0.5,
                               minSize,
                               minSize)
        metalLayer.frame = frame
    }
}

// 旋转相关--修改缓冲区（需要修改着色器的顶点）
extension ViewController {
    
    /************************** 旋转相关 ****************************/
    // MARK: - 设置旋转矩阵
    
    func update() {
        // 创建旋转矩阵
        uniforms = Uniforms(rotation_matrix: rotation_matrix_2d(rotationAngle))
        // 获取旋转缓冲区
        let bufferPointer = uniformBuffer.contents()
        // 将旋转矩阵拷贝到旋转缓冲区
        memcpy(bufferPointer, &uniforms, sizeof(Uniforms))
        // 变换角度
        rotationAngle += 0.01
    }
    
    // 旋转矩阵计算
    func rotation_matrix_2d(radians: Float) -> matrix_float4x4 {
        let cos = cosf(radians)
        let sin = sinf(radians)
        let columns0 = vector_float4([ cos, sin, 0, 0])
        let columns1 = vector_float4([-sin, cos, 0, 0])
        let columns2 = vector_float4([   0,   0, 1, 0])
        let columns3 = vector_float4([   0,   0, 0, 1])
        
        return matrix_float4x4(columns: (columns0, columns1, columns2, columns3))
    }
}


