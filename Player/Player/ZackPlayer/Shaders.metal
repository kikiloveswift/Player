//
//  Shaders.metal
//  Player
//
//  Created by kong on 2021/6/14.
//

#include <metal_stdlib>
using namespace metal;

struct InputVertexIO {
    float4 position [[position]];
    float2 textureCoordinate [[user(textureCoord)]];
};

vertex InputVertexIO vertex_main(const device packed_float2 *position [[buffer(0)]],
                                 const device packed_float2 *textureCoord [[buffer(1)]],
                                 uint vid [[vertex_id]]) {
    InputVertexIO outputVertex;
    outputVertex.position = float4(position[vid], 0, 1.0);
    outputVertex.textureCoordinate = textureCoord[vid];
    return outputVertex;
}

fragment half4 fragment_main(InputVertexIO fragmentInput [[stage_in]],
                             texture2d<half> inputTexture [[texture(0)]]) {
    constexpr sampler quadSampler;
    half4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
//    color.rgb = texture2d<<#typename T#>, <#access a#>, <#typename _Enable#>>
    return color;
}

//struct VertextIn {
//    float4 position [[attribute(0)]];
//};
//
//vertex float4 vertex_main(const VertextIn vertex_in [[ stage_in]]) {
//    return vertex_in.position;
//}
//
//fragment float4 fragment_main() {
//    return float4(1, 0.4, 0.21, 1);
//}

