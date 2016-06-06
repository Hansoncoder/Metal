/*
 * Copyright (C) 2015 Josh A. Beam
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *   1. Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *   2. Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import Foundation

struct Matrix4 {
    var matrix: [Float] = [
        1.0, 0.0, 0.0, 0.0,
        0.0, 1.0, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0,
        0.0, 0.0, 0.0, 1.0
    ]

    
    static func perspectiveMatrix(fov fov: Float, aspect: Float, near: Float, far: Float) -> Matrix4 {
        var matrix = Matrix4()
        let f = 1.0 / tanf(fov / 2.0)

        matrix.matrix[0] = f / aspect
        matrix.matrix[5] = f
        matrix.matrix[10] = (far + near) / (near - far)
        matrix.matrix[11] = -1.0
        matrix.matrix[14] = (2.0 * far * near) / (near - far)
        matrix.matrix[15] = 0.0

        return matrix
    }

    /**
     平移变换
     
     - parameter x: 沿x轴方向平移（值域[-1,1]）
     - parameter y: 沿y轴方向平移（值域[-1,1]）
     - parameter z: 沿z轴方向平移（值域[-1,1]）
     
     - returns: 返回平移后的基数值（需要使用原始值 * 基数值）
     */
    static func translationMatrix(x x: Float, y: Float, z: Float) -> Matrix4 {
        var matrix = Matrix4()

        matrix.matrix[12] = x
        matrix.matrix[13] = y
        matrix.matrix[14] = z

        return matrix
    }

    static func rotationMatrix(angle angle: Float, x: Float, y: Float, z: Float) -> Matrix4 {
        var matrix = Matrix4()

        let c = cosf(angle)
        let ci = 1.0 - c
        let s = sinf(angle)

        // 这里使用变量减少计算次数（设计思想：空间换取时间）
        let xy = x * y * ci
        let xz = x * z * ci
        let yz = y * z * ci
        let xs = x * s
        let ys = y * s
        let zs = z * s

        matrix.matrix[0] = x * x * ci + c
        matrix.matrix[1] = xy + zs
        matrix.matrix[2] = xz - ys
        matrix.matrix[4] = xy - zs
        matrix.matrix[5] = y * y * ci + c
        matrix.matrix[6] = yz + xs
        matrix.matrix[8] = xz + ys
        matrix.matrix[9] = yz - xs
        matrix.matrix[10] = z * z * ci + c

        return matrix
    }
    
    /**
     根据x、y、z轴旋转
     
     - parameter xAngleRad: 根据x轴旋转的弧度
     - parameter yAngleRad: 根据y轴旋转的弧度
     - parameter zAngleRad: 根据z轴旋转的弧度
     
     - returns: 旋转后的基数值（需要使用原始值 * 基数值）
     */
    static func rotateAround(xAngleRad xAngleRad: Float, yAngleRad: Float, zAngleRad: Float) -> Matrix4 {
        var matrix = Matrix4()
        if xAngleRad != 0.0 {
            matrix = matrix * rotationMatrix(angle: xAngleRad, x: 1, y: 0, z: 0)
        }
        if yAngleRad != 0.0 {
            matrix = matrix * rotationMatrix(angle: yAngleRad, x: 0, y: 1, z: 0)
        }
        if zAngleRad != 0.0 {
            matrix = matrix * rotationMatrix(angle: zAngleRad, x: 0, y: 0, z: 1)
        }
        return matrix
    }
    
    /** 对4*4的矩阵缩放 */
    static func scale(sx sx: Float, sy: Float, sz: Float) -> Matrix4 {
        var matrix = Matrix4()
        matrix.matrix[0] *= sx
        matrix.matrix[1] *= sx
        matrix.matrix[2] *= sx
        matrix.matrix[3] *= sx
        matrix.matrix[4] *= sy
        matrix.matrix[5] *= sy
        matrix.matrix[6] *= sy
        matrix.matrix[7] *= sy
        matrix.matrix[8] *= sz
        matrix.matrix[9] *= sz
        matrix.matrix[10] *= sz
        matrix.matrix[11] *= sz
        return matrix
    }
}

/** 角度变弧度 */
func degreesToRadians(degrees: Float) -> Float {
    return degrees * (Float(M_PI) / 180)
}

// 重载 * 号运算符
func * (left: Matrix4, right: Matrix4) -> Matrix4 {
    let m1 = left.matrix
    let m2 = right.matrix
    var m = [Float](count: 16, repeatedValue: 0.0)

    Matrix4.translationMatrix(x: 1, y: 2, z: 3)

    m[ 0] = m1[ 0]*m2[ 0] + m1[ 1]*m2[ 4] + m1[ 2]*m2[ 8] + m1[ 3]*m2[12]
    m[ 1] = m1[ 0]*m2[ 1] + m1[ 1]*m2[ 5] + m1[ 2]*m2[ 9] + m1[ 3]*m2[13]
    m[ 2] = m1[ 0]*m2[ 2] + m1[ 1]*m2[ 6] + m1[ 2]*m2[10] + m1[ 3]*m2[14]
    m[ 3] = m1[ 0]*m2[ 3] + m1[ 1]*m2[ 7] + m1[ 2]*m2[11] + m1[ 3]*m2[15]
    m[ 4] = m1[ 4]*m2[ 0] + m1[ 5]*m2[ 4] + m1[ 6]*m2[ 8] + m1[ 7]*m2[12]
    m[ 5] = m1[ 4]*m2[ 1] + m1[ 5]*m2[ 5] + m1[ 6]*m2[ 9] + m1[ 7]*m2[13]
    m[ 6] = m1[ 4]*m2[ 2] + m1[ 5]*m2[ 6] + m1[ 6]*m2[10] + m1[ 7]*m2[14]
    m[ 7] = m1[ 4]*m2[ 3] + m1[ 5]*m2[ 7] + m1[ 6]*m2[11] + m1[ 7]*m2[15]
    m[ 8] = m1[ 8]*m2[ 0] + m1[ 9]*m2[ 4] + m1[10]*m2[ 8] + m1[11]*m2[12]
    m[ 9] = m1[ 8]*m2[ 1] + m1[ 9]*m2[ 5] + m1[10]*m2[ 9] + m1[11]*m2[13]
    m[10] = m1[ 8]*m2[ 2] + m1[ 9]*m2[ 6] + m1[10]*m2[10] + m1[11]*m2[14]
    m[11] = m1[ 8]*m2[ 3] + m1[ 9]*m2[ 7] + m1[10]*m2[11] + m1[11]*m2[15]
    m[12] = m1[12]*m2[ 0] + m1[13]*m2[ 4] + m1[14]*m2[ 8] + m1[15]*m2[12]
    m[13] = m1[12]*m2[ 1] + m1[13]*m2[ 5] + m1[14]*m2[ 9] + m1[15]*m2[13]
    m[14] = m1[12]*m2[ 2] + m1[13]*m2[ 6] + m1[14]*m2[10] + m1[15]*m2[14]
    m[15] = m1[12]*m2[ 3] + m1[13]*m2[ 7] + m1[14]*m2[11] + m1[15]*m2[15]

    return Matrix4(matrix: m)
}