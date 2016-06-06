//
//  ViewController.swift
//  MetalCube
//
//  Created by Hanson on 16/6/3.
//  Copyright © 2016年 Hanson. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var device: MTLDevice! = nil
    var metalLayer: CAMetalLayer! = nil
    var pipelineState: MTLRenderPipelineState! = nil
    var commandQueue: MTLCommandQueue! = nil
    var timer: CADisplayLink! = nil
    var cube: Cube!
    var projectionMatrix: Matrix4!
    var worldModelMatrix: Matrix4!
    var backgroundColor: MTLClearColor!
    
    var lastFrameTimestamp: CFTimeInterval = 0.0
    var rotaion: Float = 0.0;
    
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
        
        // 1.1 创建一个CAMetalLayer
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .BGRA8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.layer.frame
        view.layer.addSublayer(metalLayer)
        
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
    
    
    /// 五步完成渲染
    private func displayContent() {
        
        // 2.0 创建一个Display link
        cube = Cube(device: device)
        
        // 设置透视窗口
        projectionMatrix = Matrix4.perspectiveMatrix(fov: degreesToRadians(85.0), aspect: Float(self.view.bounds.size.width / self.view.bounds.size.height), near: 0.01, far: 100)
        
        // 对正方体做初始变换（沿z轴移动-5.0，按y轴旋转45度）
        worldModelMatrix = Matrix4.translationMatrix(x: 0.0, y: 0.0, z: -5.0)
        worldModelMatrix = Matrix4.rotateAround(xAngleRad: 0.0, yAngleRad: degreesToRadians(-45), zAngleRad: 0.0) * worldModelMatrix
        backgroundColor = MTLClearColor(red: 1, green: 1, blue: 1, alpha: 1)

        timer = CADisplayLink(target: self, selector: #selector(ViewController.gameloop))
        timer.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    }
    
    
    func render() {
        
        guard let drawable = metalLayer.nextDrawable() else { return }
        
        // 设置根据z轴旋转
        rotaion += 1
        rotaion %= 360
        cube.rotationZ = degreesToRadians(rotaion)
        
        // 调用渲染方法
        cube.render(commandQueue, pipelineState: pipelineState, drawable: drawable, parentModelViewMatrix: worldModelMatrix, projectionMatrix: projectionMatrix, clearColor: backgroundColor)
        
    }
    
    // 该方法每秒调用60次
    func gameloop() {
        autoreleasepool {
            self.render()
        }
    }
}

