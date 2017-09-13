//
//  Functions.metal
//  MeshLine
//
//  Created by Hiroaki Yamane on 9/3/17.
//
//  Ported to .metal from https://github.com/spite/THREE.MeshLine/blob/master/src/THREE.MeshLine.js

#include <metal_stdlib>
using namespace metal;
#include <SceneKit/scn_metal>

struct NodeBuffer{
    float4x4 modelTransform;
    float4x4 inverseModelTransform;
    float4x4 modelViewTransform;
    float4x4 inverseModelViewTransform;
    float4x4 normalTransform; // This is the inverseTransposeModelViewTransform, need for normal transformation
    float4x4 modelViewProjectionTransform;
    float4x4 inverseModelViewProjectionTransform;
    float2x3 boundingBox;
    float2x3 worldBoundingBox;
};


struct CustomBuffer {
    float4 position [[ attribute(SCNVertexSemanticPosition) ]];
    float3 normal [[ attribute(SCNVertexSemanticNormal) ]];
    float4 tangent [[ attribute(SCNVertexSemanticTangent) ]];
//    Misc misc [[ attribute(SCNVertexSemanticBoneWeights) ]];
    float3 misc [[ attribute(SCNVertexSemanticBoneWeights) ]];
    float2 texcoords [[attribute(SCNVertexSemanticTexcoord0)]];
};

struct VertexOut {
    float4 position [[ position ]];
    float pointSize [[ point_size ]];
    float4 color;
    float2 texcoords;
    float counters;
    
};

/* Uniforms */
struct Uniform {
    float lineWidth;
    float useMap;
    float useAlphaMap;
    float4 color;
    float opacity;
    float2 resolution;
    float sizeAttenuation;
    float near;
    float far;
    float2 dashArray;
    float useDash;
    float visibility;
    float alphaTest;
    float2 repeating;
};

float2 fixPos( float4 i, float _aspect ) {
    float2 res = i.xy / i.w;
    res.x *= _aspect;
    return res;
}


struct Misc {
    float counter;
    float side;
    float width;
};


vertex VertexOut vertexFunction(CustomBuffer _geometry [[ stage_in ]],
                       constant SCNSceneBuffer& scn_frame [[ buffer(0) ]],
                       constant NodeBuffer& scn_node [[ buffer(1) ]],
                       constant Uniform &uniforms [[ buffer(2) ]] ) {

    // expanding misc info
    float width = _geometry.misc.z;
    float side = _geometry.misc.y;
    float counters = _geometry.misc.x;

    float sizeAttenuation = uniforms.sizeAttenuation;
    float2 resolution = uniforms.resolution;
    
    float aspect = resolution.x / resolution.y;
    float pixelWidthRatio = 1.0 / (resolution.x * scn_frame.projectionTransform[0][0]);
    float4x4 m = scn_frame.projectionTransform * scn_node.modelViewTransform;
    float4 finalPosition = m * _geometry.position;
    float4 prevPos = m * float4( _geometry.normal, 1.0 );
    float4 nextPos = m * float4( _geometry.tangent.xyz, 1.0 );
    
    float2 currentP = fixPos(finalPosition, aspect);
    float2 prevP = fixPos(prevPos, aspect);
    float2 nextP = fixPos(nextPos, aspect);
    
    float pixelWidth = finalPosition.w * pixelWidthRatio;
    float w = 1.8 * pixelWidth * uniforms.lineWidth * width;
    
    if ( sizeAttenuation == 1.0 ) {
        w = 1.8 * uniforms.lineWidth * width;
    }
    
    float2 dir;
    if ( nextP.x == currentP.x && nextP.y == currentP.y ) { dir = normalize( currentP - prevP ); }
    else if ( prevP.x == currentP.x && prevP.y == currentP.y ) { dir = normalize( nextP - currentP ); }
    else {
        float2 dir1 = normalize( currentP - prevP );
        float2 dir2 = normalize( nextP - currentP );
        dir = normalize( dir1 + dir2 );
        //    float2 perp = float2( -dir1.y, dir1.x );
        //    float2 miter = float2( -dir.y, dir.x );
        //w = clamp( w / dot( miter, perp ), 0., 4. * lineWidth * width );
    }
    
//    float2 normal = ( cross( float3( dir, 0 ), float3( 0, 0, 1 ) ) ).xy;
    float2 normal = float2(-dir.y, dir.x);
    normal.x /= aspect;
    normal *= .5 * w;
    
    float4 offset = float4( normal * side, 0.0, 1.0 );
    finalPosition.xy += offset.xy;
    VertexOut out;
    out.position = finalPosition;
    out.color = float4( uniforms.color.xyz, uniforms.opacity );
    out.texcoords = _geometry.texcoords;
    out.counters = counters;
    out.pointSize = 3.0;
    return out;
};



fragment half4 fragmentFunction(VertexOut in [[ stage_in ]],
                               constant Uniform &uniforms [[buffer(0)]]) {
    constexpr sampler defaultSampler;
    float4 color = in.color;
//    // if ( useMap == 1.0 ) { c *= uniforms.map.sample( defaultSampler, in.texcoords * uniforms.repeating ); }
//    // if ( useAlphaMap == 1.0 ) { c.a *= uniforms.alphaMap.sample( defaultSampler, in.texcoords * uniforms.repeating ).a; }
//    if ( color.a < uniforms.alphaTest ) {
//        discard_fragment();
//    }
//    if ( uniforms.useDash == 1.0 ) {}
//    color.a *= step( in.counters, uniforms.visibility );
    return half4(color);
}
