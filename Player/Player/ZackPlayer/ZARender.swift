//
//  ZARender.swift
//  Player
//
//  Created by kong on 2021/6/14.
//

import UIKit

class ZARender: UIView {

    private var device: MTLDevice?

    private var commandQueue: MTLCommandQueue?

    private var pipelineState: MTLRenderPipelineState?

    private var metalLayer: CAMetalLayer?

    private var vertexBuffer: MTLBuffer?

    override class var layerClass: AnyClass {
        return CAMetalLayer.self
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupMetal()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupMetal() {
        guard let metalDevice = MTLCreateSystemDefaultDevice(),
              let queue = metalDevice.makeCommandQueue() else {
            fatalError()
        }
        device = metalDevice
        commandQueue = queue

        let library = device?.makeDefaultLibrary()
        let vertexFun = library?.makeFunction(name: "vertex_main")
        let fragmentFunc = library?.makeFunction(name: "fragment_main")

        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexFun
        pipelineStateDescriptor.fragmentFunction = fragmentFunc
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

        pipelineState = try? device?.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
    }

    func setupMetalLayer() {
        let mLayer = CAMetalLayer()
        mLayer.device = device
        mLayer.pixelFormat = .bgra8Unorm
        mLayer.framebufferOnly = true
        self.layer.addSublayer(mLayer)
        self.metalLayer = mLayer
    }

    func render() {
        guard let mLayer = self.metalLayer,
              let drawable = mLayer.nextDrawable() else {
            return
        }
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)

        guard let commandBuffer = commandQueue?.makeCommandBuffer(),
              let pipelineState = pipelineState else {
            return
        }

        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        renderEncoder?.setRenderPipelineState(pipelineState)
//        renderEncoder?.setVertexBuffer(, offset: <#T##Int#>, index: <#T##Int#>)
//        CVMetalTextureCacheCreate(<#T##allocator: CFAllocator?##CFAllocator?#>, <#T##cacheAttributes: CFDictionary?##CFDictionary?#>, <#T##metalDevice: MTLDevice##MTLDevice#>, <#T##textureAttributes: CFDictionary?##CFDictionary?#>, <#T##cacheOut: UnsafeMutablePointer<CVMetalTextureCache?>##UnsafeMutablePointer<CVMetalTextureCache?>#>)
    }



}


extension ZARender: ReaderDelegate {

    func processPixelBuffer(_ pixbuffer: CVPixelBuffer, size: CGSize) {

    }
}
