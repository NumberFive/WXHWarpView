//
//  WXHMovePointView.m
//  Demo
//
//  Created by Jerry on 2018/1/11.
//  Copyright © 2018年 Jerry. All rights reserved.
//
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

#import "WXHMovePointView.h"
@interface WXHMovePointView ()
@property (nonatomic, strong) UIPanGestureRecognizer *gestureLeftBottom;
@property (nonatomic, strong) UIPanGestureRecognizer *gestureRightBottom;
@property (nonatomic, strong) UIPanGestureRecognizer *gestureLeftUp;
@property (nonatomic, strong) UIPanGestureRecognizer *gestureRightUp;
@property (nonatomic, strong) UIPanGestureRecognizer *gestureCenter;
@end

static CGPoint pointOfIntersectionForTwoLines(CGPoint positionA, CGPoint positionB,CGPoint positionC, CGPoint positionD);
static CGPoint pointFromLineByRatio(CGPoint positionA, CGPoint positionB, float ratio);
static CGPoint middleFromTwoPoint(CGPoint positionA, CGPoint positionB);

@implementation WXHMovePointView
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)]) {
        self.multipleTouchEnabled = YES;
        
        UIView *leftBottomView = [self movePointView];
        leftBottomView.center = CGPointMake(frame.origin.x, frame.origin.y+frame.size.height);
        [self addSubview:leftBottomView];
        
        self.gestureLeftBottom = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
        [leftBottomView addGestureRecognizer:self.gestureLeftBottom];
        
        UIView *rightBottomView = [self movePointView];
        rightBottomView.center = CGPointMake(frame.origin.x+frame.size.width, frame.origin.y+frame.size.height);
        [self addSubview:rightBottomView];
        self.gestureRightBottom = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
        [rightBottomView addGestureRecognizer:self.gestureRightBottom];
        
        UIView *leftUpView = [self movePointView];
        leftUpView.center = CGPointMake(frame.origin.x, frame.origin.y);
        [self addSubview:leftUpView];
        
        self.gestureLeftUp = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
        [leftUpView addGestureRecognizer:self.gestureLeftUp];
        
        UIView *rightUpView = [self movePointView];
        rightUpView.center = CGPointMake(frame.origin.x+frame.size.width, frame.origin.y);
        [self addSubview:rightUpView];
        self.gestureRightUp = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
        [rightUpView addGestureRecognizer:self.gestureRightUp];
        
        UIView *centerView = [self movePointView];
        [self addSubview:centerView];
        
        self.gestureCenter = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
        [centerView addGestureRecognizer:self.gestureCenter];
        self.gestureCenter.enabled = NO;
        
        [self refreshCenterPoint];
    }
    return self;
}

- (void)panGestureAction:(UIPanGestureRecognizer *)panGesture
{
    CGPoint point = [panGesture translationInView:self];
    [panGesture setTranslation:CGPointZero inView:self];
    
    UIView *view = panGesture.view;
    CGPoint centerPoint = view.center;
    centerPoint.x += point.x;
    centerPoint.y += point.y;
    view.center = centerPoint;
    
    [self refreshCenterPoint];
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(pointDidMoveLeftUpPoint:rightUpPoint:leftBottomPoint:rightBottomPoint:)]) {
        [self.delegate pointDidMoveLeftUpPoint:self.gestureLeftUp.view.center
                                    rightUpPoint:self.gestureRightUp.view.center
                                 leftBottomPoint:self.gestureLeftBottom.view.center
                                rightBottomPoint:self.gestureRightBottom.view.center];
    }
}
- (void)refreshCenterPoint
{
    CGPoint leftMiddleCenter = middleFromTwoPoint(self.gestureLeftUp.view.center,self.gestureLeftBottom.view.center);
    CGPoint rightMiddleCenter = middleFromTwoPoint(self.gestureRightUp.view.center,self.gestureRightBottom.view.center);
    CGPoint upMiddelCenter = middleFromTwoPoint(self.gestureLeftUp.view.center,self.gestureRightUp.view.center);
    CGPoint bottoMiddleCenter = middleFromTwoPoint(self.gestureLeftBottom.view.center,self.gestureRightBottom.view.center);
    
    self.gestureCenter.view.center = pointOfIntersectionForTwoLines(leftMiddleCenter,
                                                                    rightMiddleCenter,
                                                                    upMiddelCenter,
                                                                    bottoMiddleCenter);
}


//求两个线段AB与CD的交点位置
CGPoint pointOfIntersectionForTwoLines(CGPoint positionA, CGPoint positionB,CGPoint positionC, CGPoint positionD)
{
    CGFloat b1 = (positionB.y - positionA.y) * positionA.x + (positionA.x - positionB.x) * positionA.y;
    CGFloat b2 = (positionD.y - positionC.y) * positionC.x + (positionC.x - positionD.x) * positionC.y;
    
    CGFloat d = (positionB.x - positionA.x) * (positionD.y - positionC.y) - (positionD.x - positionC.x) * (positionB.y - positionA.y);
    CGFloat d1 = b2 * (positionB.x - positionA.x) - b1 * (positionD.x - positionC.x);
    CGFloat d2 = b2 * (positionB.y - positionA.y) - b1 * (positionD.y - positionC.y);
    
    return CGPointMake(fabs(d1 / d), fabs(d2 / d));
}
//求AB两点的连线上的任意点的位置，该点在线段上到A点与到B点的比例为：ratio
CGPoint pointFromLineByRatio(CGPoint positionA, CGPoint positionB, float ratio)
{
    return CGPointMake((positionA.x + ratio * positionB.x) / (1 + ratio),
                       (positionA.y + ratio * positionB.y) / (1 + ratio));
}
//求AB两点的连线上的中点
CGPoint middleFromTwoPoint(CGPoint positionA, CGPoint positionB)
{
    return pointFromLineByRatio(positionA, positionB, 1);
}

#pragma mark - Setter And Getter Method
- (CGPoint)leftUpPoint
{
    return self.gestureLeftUp.view.center;
}

- (CGPoint)rightUpPoint
{
    return self.gestureRightUp.view.center;
}
- (CGPoint)leftBottomPoint
{
    return self.gestureLeftBottom.view.center;
}
- (CGPoint)rightBottomPoint
{
    return self.gestureRightBottom.view.center;
}
- (CGPoint)centerPoint
{
    return self.gestureCenter.view.center;
}

- (UIView *)movePointView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    view.backgroundColor = [UIColor brownColor];
    view.alpha = 0.7;
    return view;
}
@end
