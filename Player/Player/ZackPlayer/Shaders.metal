//
//  Shaders.metal
//  Player
//
//  Created by kong on 2021/6/14.
//

#include <metal_stdlib>
using namespace metal;

struct VertextIn {
    float4 position [[attribute(0)]];
};

vertex float4 vertex_main(const VertextIn vertex_in [[ stage_in]]) {
    return vertex_in.position;
}

fragment float4 fragment_main() {
    return float4(1, 0.4, 0.21, 1);
}

