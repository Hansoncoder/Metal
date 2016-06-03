//
//  SquareShader.metal
//  MetalDemo
//
//  Created by Hanson on 16/6/2.
//  Copyright © 2016年 Hanson. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

typedef struct
{
    float4x4 rotation_matrix;
} Uniforms;

typedef struct
{
    float4 position;
    float4 color;
} VertexIn;

typedef struct {
    float4 position [[position]];
    half4  color;
} VertexOut;


/// 传入一个vertices顶点数据，&uniforms旋转矩阵的引用，vid顶点索引

vertex VertexOut basic_vertex(device VertexIn *vertices [[buffer(0)]],
                              constant Uniforms &uniforms [[buffer(1)]],
                              uint vid [[vertex_id]])
{
    VertexOut out;
    out.position = uniforms.rotation_matrix * vertices[vid].position;
    out.color = half4(vertices[vid].color);
    return out;
}

fragment half4 basic_fragment(VertexOut in [[stage_in]])
{
    return in.color;
}