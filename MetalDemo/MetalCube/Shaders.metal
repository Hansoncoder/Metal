//
//  Shaders.metal
//  MetalDemo
//
//  Created by Hanson on 16/6/3.
//  Copyright © 2016年 Hanson. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

typedef struct
{
    float4 position;
    float4 color;
} VertexIn;

typedef struct {
    float4 position [[position]];
    half4  color;
} VertexOut;

typedef struct {
    float4x4 modelMatrix;
    float4x4 projectionMatrix;
} Uniforms;

/// 传入一个vertices顶点数据，vid顶点索引

vertex VertexOut basic_vertex(device VertexIn *vertices [[buffer(0)]],
                              const device Uniforms& uniforms [[ buffer(1) ]],
                              uint vid [[vertex_id]]) {
    
    float4x4 mv_Matrix = uniforms.modelMatrix;
    float4x4 proj_Matrix = uniforms.projectionMatrix;
    
    VertexOut out;
    out.position = proj_Matrix * mv_Matrix * vertices[vid].position;
    out.color = half4(vertices[vid].color);
    return out;
}

fragment half4 basic_fragment(VertexOut in [[stage_in]]) {
    return in.color;
}