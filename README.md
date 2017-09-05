# MeshLine for SceneKit [wip]

Super rough SceneKit port of [@thespite](https://twitter.com/thespite)'s [THREE.MeshLine](https://github.com/spite/THREE.MeshLine/)

![](http://c.mnmly.com/mLMy/MeshLineDemo.gif)

### Usage

```swift
let node = MeshLineNode()
let material = MeshLineMaterial()
var _vertices: [SCNVector3] = []
for i in 0..<360 {
    let phase = Float(i) / Float(360)
    let x = CGFloat(i) / 300.0;
    let y = CGFloat(sin( phase * 20.0 ) * 0.1);
    let z = CGFloat(cos( phase * 30.0) * 1.0 );
    _vertices.append(SCNVector3(x: x, y: y, z: z))
}
node.setVertices(vertices: _vertices)
node.geometry?.materials = [material]
```

*Since it's in Metal, it only works on iOS Device and macOS*