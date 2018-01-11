//
//  SceneWarpMesh.m
//  OpenglES
//
//  Created by WXH on 16/3/5.
//  Copyright © 2016年 WXH. All rights reserved.
//

#import "SceneWarpMesh.h"

/////////////////////////////////////////////////////////////////
// Constants that control the size of the mesh
#define NUM_MESH_ROWS (20)     // Must be at least 2
#define NUM_MESH_COLUMNS (20)  // Must be at least 2
#define NUM_MESH_TRIANGLES ((NUM_MESH_ROWS - 1) * \
(NUM_MESH_COLUMNS - 1) * 2)

/////////////////////////////////////////////////////////////////
// The number of indices is the number of triangles in mesh
// plus 2 plus number degenerate triangles (NUM_MESH_COLUMNS - 2)
#define NUM_MESH_INDICES (NUM_MESH_TRIANGLES + 2 + \
(NUM_MESH_COLUMNS - 2))

#define NUM_VECTORS (4)
#define MIN_DEPTH (-7)

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

@interface SceneWarpMesh ()
{
    SceneMeshVertex  mesh[NUM_MESH_COLUMNS][NUM_MESH_ROWS];
    GLKVector3  vertices[NUM_VECTORS];
}

@end

static void SceneMeshInitIndices(GLushort meshIndices[NUM_MESH_INDICES]);

static void SceneMeshUpdateMeshWithDefaultPositions(GLKVector3  vertices[NUM_VECTORS],
                                                    SceneMeshVertex mesh[NUM_MESH_COLUMNS][NUM_MESH_ROWS]);

static void scalarToVector(CGPoint leftBottomPoint,
                           CGPoint rightBottomPoint,
                           CGPoint leftUpPoint,
                           CGPoint rightUpPoint,
                           GLKVector3  vertices[]);

static void lineSeparated(GLKVector3 positionA, GLKVector3 positionB,int num, GLKVector3 array[]);

@implementation SceneWarpMesh

- (id)initWithLeftBottomPoint:(CGPoint)leftBottomPoint
             rightBottomPoint:(CGPoint)rightBottomPoint
                  leftUpPoint:(CGPoint)leftUpPoint
                 rightUpPoint:(CGPoint)rightUpPoint
{
    GLushort meshIndices[NUM_MESH_INDICES];
    
    // Setup indices
    SceneMeshInitIndices(meshIndices);
    
    scalarToVector(leftBottomPoint, rightBottomPoint, leftUpPoint, rightUpPoint, vertices);
    // Setup default positions and texture coordiantes
    SceneMeshUpdateMeshWithDefaultPositions(vertices, mesh);
    
    // Create the NSData objects needed by super class.
    NSData *someMeshData = [NSData dataWithBytesNoCopy:mesh
                                                length:sizeof(mesh) freeWhenDone:NO];
    NSData *someIndexData = [NSData dataWithBytes:meshIndices
                                           length:sizeof(meshIndices)];
    
    self = [self initWithVertexAttributeData:someMeshData
                                   indexData:someIndexData];
    
    self.leftBottomPoint = leftBottomPoint;
    self.rightBottomPoint = rightBottomPoint;
    self.leftUpPoint = leftUpPoint;
    self.rightUpPoint = rightUpPoint;
    
    return self;
}
void scalarToVector(CGPoint leftBottomPoint,
                    CGPoint rightBottomPoint,
                    CGPoint leftUpPoint,
                    CGPoint rightUpPoint,
                    GLKVector3  vertices[NUM_VECTORS])
{
    GLKVector3 aLeftBottomPoint = coordinateExchange(leftBottomPoint);
    GLKVector3 aLeftUpPoint = coordinateExchange(leftUpPoint);
    
    GLKVector3 aRightBottomPoint = coordinateExchange(rightBottomPoint);
    GLKVector3 aRightUpPoint = coordinateExchange(rightUpPoint);
    
    float leftVerticalLength = fabsf(aLeftBottomPoint.y - aLeftUpPoint.y);
    float rightVerticalLength = fabsf(aRightBottomPoint.y - aRightUpPoint.y);
    
    float upHorizontalLength = fabsf(aLeftUpPoint.x - aRightUpPoint.x);
    float bottomHorizontalLength = fabsf(aLeftBottomPoint.x - aRightBottomPoint.x);
    
    if (leftVerticalLength < rightVerticalLength) {
        float depth = 1 - rightVerticalLength / leftVerticalLength;
        depth =  depth < MIN_DEPTH ? MIN_DEPTH : depth;
        aLeftUpPoint.z += depth;
        aLeftBottomPoint.z += depth;
    } else {
        float depth = 1- leftVerticalLength / rightVerticalLength;
        depth =  depth < MIN_DEPTH ? MIN_DEPTH : depth;
        aRightUpPoint.z += depth;
        aRightBottomPoint.z += depth;
    }
    
    if (upHorizontalLength < bottomHorizontalLength) {
        float depth = 1 - bottomHorizontalLength / upHorizontalLength;
        depth =  depth < MIN_DEPTH ? MIN_DEPTH : depth;
        aLeftUpPoint.z += depth;
        aRightUpPoint.z += depth;
    } else {
        float depth = 1 - upHorizontalLength / bottomHorizontalLength;
        depth =  depth < MIN_DEPTH ? MIN_DEPTH : depth;
        aLeftBottomPoint.z += depth;
        aRightBottomPoint.z += depth;
    }
    
    vertices[0] = vectorMatchingDepth(aLeftBottomPoint);
    vertices[1] = vectorMatchingDepth(aRightBottomPoint);
    vertices[2] = vectorMatchingDepth(aLeftUpPoint);
    vertices[3] = vectorMatchingDepth(aRightUpPoint);
}
GLKVector3 vectorMatchingDepth(GLKVector3 point)
{
    return GLKVector3Make(point.x*(fabsf(point.z)+1), point.y*(fabsf(point.z)+1), point.z);
}
void SceneMeshInitIndices(GLushort meshIndices[NUM_MESH_INDICES])
{
    int    currentRow = 0;
    int    currentColumn = 0;
    int    currentMeshIndex = 0;
    
    // Start at 1 because algorithm steps back one index at start
    currentMeshIndex = 1;
    
    // For each position along +X axis of mesh
    for(currentColumn = 0; currentColumn < (NUM_MESH_COLUMNS - 1);
        currentColumn++)
    {
        if(0 == (currentColumn % 2))
        { // This is an even column
            currentMeshIndex--; // back: overwrite duplicate vertex
            
            // For each position along -Z axis of mesh
            for(currentRow = 0; currentRow < NUM_MESH_ROWS; currentRow++)
            {
                meshIndices[currentMeshIndex++] = currentColumn * NUM_MESH_ROWS + currentRow;
                meshIndices[currentMeshIndex++] = (currentColumn + 1) * NUM_MESH_ROWS + currentRow;
            }
        }
        else
        { // This is an odd column
            currentMeshIndex--; // back: overwrite duplicate vertex
            
            // For each position along -Z axis of mesh
            for(currentRow = NUM_MESH_ROWS - 1; currentRow >= 0; currentRow--)
            {
                meshIndices[currentMeshIndex++] = currentColumn * NUM_MESH_ROWS + currentRow;
                meshIndices[currentMeshIndex++] = (currentColumn + 1) * NUM_MESH_ROWS + currentRow;
            }
        }
    }
    
    NSCAssert(currentMeshIndex == NUM_MESH_INDICES, @"Incorrect number of indices intialized.");
}

GLKVector3 coordinateExchange(CGPoint point)
{
    return GLKVector3Make(point.x/(SCREEN_WIDTH/2.0)-1, 1-point.y/(SCREEN_HEIGHT/2.0), 0);
}

void SceneMeshUpdateMeshWithDefaultPositions(GLKVector3  vertices[NUM_VECTORS],
                                             SceneMeshVertex mesh[NUM_MESH_COLUMNS][NUM_MESH_ROWS])
{
    int    currentRow;
    int    currentColumn;
    
    GLKVector3 rowArrayA[NUM_MESH_COLUMNS];
    GLKVector3 rowArrayB[NUM_MESH_COLUMNS];
    GLKVector3 columnArrayA[NUM_MESH_ROWS];
    GLKVector3 columnArrayB[NUM_MESH_ROWS];
    
    lineSeparated(vertices[0],vertices[1],NUM_MESH_COLUMNS-1,rowArrayA);
    lineSeparated(vertices[2],vertices[3],NUM_MESH_COLUMNS-1,rowArrayB);
    lineSeparated(vertices[0],vertices[2],NUM_MESH_ROWS-1,columnArrayA);
    lineSeparated(vertices[1],vertices[3],NUM_MESH_ROWS-1,columnArrayB);
    
    // For each position along +X axis of mesh
    for(currentColumn = 0; currentColumn < NUM_MESH_COLUMNS; currentColumn++)
    {
        
        // For each position along -Z axis of mesh
        for(currentRow = 0; currentRow < NUM_MESH_ROWS; currentRow++)
        {
            GLKVector3 position = pointFromLineByTotalRatio(rowArrayA[currentColumn],
                                                            rowArrayB[currentColumn],
                                                            (float)currentRow/(NUM_MESH_ROWS-1));
            if (currentRow == NUM_MESH_ROWS - 1) {
                position = rowArrayB[currentColumn];
            }
            mesh[currentColumn][currentRow].position = position;
            GLKVector2 textureCoords = GLKVector2Make((float)currentColumn / (NUM_MESH_COLUMNS - 1),
                                                      (float)currentRow / (NUM_MESH_ROWS - 1)
                                                      );
            mesh[currentColumn][currentRow].texCoords0 = textureCoords;
        }
    }
}

//求两点的连线上的任意点的位置，该点在线段上的比例为：ratio
GLKVector3 pointFromLineByRatio(GLKVector3 positionA, GLKVector3 positionB, float ratio)
{
    return GLKVector3Make((positionA.x + ratio * positionB.x) / (1 + ratio),
                          (positionA.y + ratio * positionB.y) / (1 + ratio),
                          (positionA.z + ratio * positionB.z) / (1 + ratio));
}
//求两点的连线上的任意点的位置，该点在线段上的总比例为：totalRatio
GLKVector3 pointFromLineByTotalRatio(GLKVector3 positionA, GLKVector3 positionB,float totalRatio)
{
    return pointFromLineByRatio(positionA, positionB, totalRatio/(1-totalRatio));
}
//一条线段被分成N等分的所有的点
void lineSeparated(GLKVector3 positionA, GLKVector3 positionB,int num, GLKVector3 array[])
{
    array[0] = positionA;
    array[num] = positionB;
    for (int i = 1 ; i < num; i++) {
        array[i] = pointFromLineByTotalRatio(positionA, positionB,i/(float)num);
    }
}
//求两个线段AB与CD的交点位置
GLKVector3 pointOfIntersectionForTwoLines(GLKVector3 positionA, GLKVector3 positionB,GLKVector3 positionC, GLKVector3 positionD)
{
    CGFloat b1 = (positionB.y - positionA.y) * positionA.x + (positionA.x - positionB.x) * positionA.y;
    CGFloat b2 = (positionD.y - positionC.y) * positionC.x + (positionC.x - positionD.x) * positionC.y;
    
    CGFloat d = (positionB.x - positionA.x) * (positionD.y - positionC.y) - (positionD.x - positionC.x) * (positionB.y - positionA.y);
    CGFloat d1 = b2 * (positionB.x - positionA.x) - b1 * (positionD.x - positionC.x);
    CGFloat d2 = b2 * (positionB.y - positionA.y) - b1 * (positionD.y - positionC.y);
    
    return GLKVector3Make(fabs(d1 / d), fabs(d2 / d), 0);
}
float distanceTwoPoint(GLKVector3 positionA,GLKVector3 positionB)
{
    float x = positionA.x - positionB.x;
    float y = positionA.y - positionB.y;
    return sqrt(x * x + y * y);
}
- (void)drawEntireMesh;
{
    // Draw triangles using vertices in the prepared vertex
    // buffers and indices from the bound element array buffer
    glDrawElements(GL_TRIANGLE_STRIP,
                   NUM_MESH_INDICES,
                   GL_UNSIGNED_SHORT,
                   (GLushort *)NULL);
}

// Revert to defualt vertex attribtes
- (void)updateMeshWithDefaultPositions;
{
    scalarToVector(self.leftBottomPoint,
                   self.rightBottomPoint,
                   self.leftUpPoint,
                   self.rightUpPoint,
                   vertices);
    
    SceneMeshUpdateMeshWithDefaultPositions(vertices,mesh);
    
    [self makeDynamicAndUpdateWithVertices:&mesh[0][0]
                          numberOfVertices:sizeof(mesh) / sizeof(SceneMeshVertex)];
}
@end
