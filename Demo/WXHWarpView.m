//
//  WXHWarpView.m
//  Demo
//
//  Created by Jerry on 2018/1/11.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

#import "WXHWarpView.h"
#import <GLKit/GLKit.h>
#import "SceneWarpMesh.h"
#import "WXHMovePointView.h"

@interface WXHWarpView ()<GLKViewDelegate,WXHMovePointViewDelegate>
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) WXHMovePointView *pointView;

@property (nonatomic, strong) GLKView *glkView;
@property (nonatomic, strong) GLKBaseEffect *baseEffect;
@property (nonatomic, strong) SceneWarpMesh *sceneWarpMesh;

@property (nonatomic, assign) GLKMatrixStackRef modelViewMaterixStack;
@property (nonatomic, strong) GLKTextureInfo *textureInfo;
@end
@implementation WXHWarpView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    if (self) {
        self.image = [UIImage imageNamed:@"1478959968.jpg"];
        
        [self addSubview:self.glkView];
        self.glkView.drawableDepthFormat = GLKViewDrawableDepthFormat24;
        self.modelViewMaterixStack = GLKMatrixStackCreate(kCFAllocatorDefault);
        
        //设置投影矩阵
        self.baseEffect.transform.projectionMatrix = GLKMatrix4MakeFrustum(-1.0, 1.0, -1.0, 1.0, 1.0, 120.0);
        
        //设置模型视图矩阵
        self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -1.0000001);
        GLKMatrixStackLoadMatrix4(self.modelViewMaterixStack, self.baseEffect.transform.modelviewMatrix);
        
        //深度测试
        glEnable(GL_DEPTH_TEST);
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        
        CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        rect.size.width /= 2.0;
        rect.size.height /= 2.0;
        rect.origin.x = (SCREEN_WIDTH - rect.size.width)/2.0;
        rect.origin.y = (SCREEN_HEIGHT - rect.size.height)/2.0;
        
        self.pointView = [[WXHMovePointView alloc] initWithFrame:rect];
        self.pointView.delegate = self;
        [self addSubview:self.pointView];
        
        CGImageRef imageRef = self.image.CGImage;
        self.textureInfo = [GLKTextureLoader textureWithCGImage:imageRef
                                                                   options:@{GLKTextureLoaderOriginBottomLeft:@YES}
                                                                     error:NULL];
        [self.glkView display];
    }
    return self;
}

#pragma mark - WXHMovePointViewDelegate
- (void)pointDidMoveLeftUpPoint:(CGPoint)leftUpPoint
                   rightUpPoint:(CGPoint)rightUpPoint
                leftBottomPoint:(CGPoint)leftBottomPoint
               rightBottomPoint:(CGPoint)rightBottomPoint
{
    self.sceneWarpMesh.leftUpPoint = leftUpPoint;
    self.sceneWarpMesh.rightUpPoint = rightUpPoint;
    self.sceneWarpMesh.leftBottomPoint = leftBottomPoint;
    self.sceneWarpMesh.rightBottomPoint = rightBottomPoint;
    
    [self.sceneWarpMesh updateMeshWithDefaultPositions];
    [self.glkView display];
}
#pragma mark - GLKViewDelegate
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    [self.sceneWarpMesh prepareToDraw];
    self.baseEffect.texture2d0.name = self.textureInfo.name;
    self.baseEffect.texture2d0.target = self.textureInfo.target;
    [self.baseEffect prepareToDraw];
    [self.sceneWarpMesh drawEntireMesh];
}
- (void)destroyGlView
{
    GLuint tag = self.textureInfo.name;
    glDeleteTextures(1, &tag);
    [self.glkView removeFromSuperview];
    self.glkView.delegate = self;
    self.glkView = nil;
    self.baseEffect = nil;
    CFRelease(self.modelViewMaterixStack);
    self.modelViewMaterixStack = nil;
    [EAGLContext setCurrentContext:nil];
}

#pragma mark - Setter / Getter
- (GLKBaseEffect *)baseEffect
{
    if (_baseEffect == nil) {
        _baseEffect = [[GLKBaseEffect alloc] init];
        
//        _baseEffect.useConstantColor = GL_TRUE;
//        _baseEffect.constantColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 0.0f);
    }
    return _baseEffect;
}
- (GLKView *)glkView
{
    if (_glkView == nil) {
        _glkView = [[GLKView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _glkView.backgroundColor = [UIColor clearColor];
        _glkView.delegate = self;
        
        _glkView.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        [EAGLContext setCurrentContext:_glkView.context];
    }
    return _glkView;
}
- (SceneWarpMesh *)sceneWarpMesh
{
    if (!_sceneWarpMesh) {
        _sceneWarpMesh = [[SceneWarpMesh alloc] initWithLeftBottomPoint:self.pointView.leftBottomPoint
                                                       rightBottomPoint:self.pointView.rightBottomPoint
                                                            leftUpPoint:self.pointView.leftUpPoint
                                                           rightUpPoint:self.pointView.rightUpPoint];
    }
    return _sceneWarpMesh;
}
@end
