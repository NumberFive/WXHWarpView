//
//  SceneWarpMesh.h
//  OpenglES
//
//  Created by WXH on 16/3/5.
//  Copyright © 2016年 WXH. All rights reserved.
//

#import "SceneMesh.h"

@interface SceneWarpMesh : SceneMesh

//左下，右下，左上，右上
@property (nonatomic, assign) CGPoint leftBottomPoint;
@property (nonatomic, assign) CGPoint rightBottomPoint;
@property (nonatomic, assign) CGPoint leftUpPoint;
@property (nonatomic, assign) CGPoint rightUpPoint;

- (id)initWithLeftBottomPoint:(CGPoint)leftBottomPoint
             rightBottomPoint:(CGPoint)rightBottomPoint
                  leftUpPoint:(CGPoint)leftUpPoint
                 rightUpPoint:(CGPoint)rightUpPoint;


- (void)drawEntireMesh;

- (void)updateMeshWithDefaultPositions;
@end
