//
//  ViewController.swift
//  MatelDemo
//
//  Created by Hanson on 16/6/1.
//  Copyright © 2016年 Hanson. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var device: MTLDevice! = nil
    var metalLayer: CAMetalLayer! = nil
    var pipelineState: MTLRenderPipelineState! = nil
    var vertexBuffer: MTLBuffer! = nil
    var commandQueue: MTLCommandQueue! = nil
    var timer: CADisplayLink! = nil
    
    let vertexData:[Float] = [
        -0.5,-0.32, 0.0,
        0.5, -0.32, 0.0,
        0.5,  0.32, 0.0,
        -0.5,-0.32, 0.0,
        -0.5, 0.32, 0.0,
        0.5, 0.32, 0.0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 初始化Metal
        setupMetal()
        // 渲染图形
        displayContent()
    }
    
    /// 七步设置Metal
    private func setupMetal() {
        
        // 1.0 创建一个MTLDevice
        device = MTLCreateSystemDefaultDevice()
        /**
         在Metal中，设备(Device)被作为GPU抽象概念，被用于去创建其他的对象，包括缓存、材质以及函数库。使用MTLCreateSystemDefaultDevice()方法可以获取默认设备:*/
        
        // 1.1 创建一个CAMetalLayer
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .BGRA8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.layer.frame
        view.layer.addSublayer(metalLayer)
        /**
         CAMetalLayer是CALayer的子类，能够表现一个Metal framebuffer中的内容。我们需要告知图层metalLayer我们使用了哪个device(就是刚刚创建的那个)，并设置其显示格式，在这里设置的是8bit通道BGRA的格式，也就是说每个像素包括蓝、绿、红以及Alpha(透明度)四个值，每个值的取值范围为0-255。*/
        
        
        // 1.2 创建一个Vertex Buffer
        let dataSize = vertexData.count * sizeofValue(vertexData[0])
        vertexBuffer = device.newBufferWithBytes(vertexData, length: dataSize, options: MTLResourceOptions.init(rawValue: 0))
        /**
         在Metal里每一个东西都是三角形。在这个应用里，你只需要画一个三角形，不过即使是极其复杂的3D形状也能被解构为一系列的三角形。
         在MTLDevice上调用newBufferWithBytes(length:options:) ，在GPU创建一个新的buffer，从CPU里输送data。你传递nil来接受默认的选项。
         */
        
        
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
        /**
         Metal中的管线编程，也就意味着顶点数据在被渲染的时候会发生不同寻常的变化，顶点着色器和片段着色器都是可编程渲染管线，另外也还有一些其他的必要的操作(比如剪切、光栅扫描、视口变换)则不需要我们直接去控制.
         最后我们利用描述符来创建管线态(pipeline state)，这样在程序运行的时候它就会根据硬件将中间代码优化之后编译着色器功能。
         */
        
        
        // 1.6 创建一个Command Queue
        commandQueue = device.newCommandQueue()
        /**
         所有指令会被集结为指令序列之后提交到Metal device，指令序列允许指令在线程安全的情况下改变或者序列化他们的执行
         */
    }
    
    
    /// 五步完成渲染
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
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, atIndex: 0)
        renderEncoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: 6, instanceCount: 1)
        renderEncoder.endEncoding()
        
        // 2.4 提交你Command Buffer的内容
        commandBuffer.presentDrawable(drawable!)
        commandBuffer.commit()
        
    }
    
    func gameloop() {
        autoreleasepool {
            self.render()
        }
    }
    
    
}



