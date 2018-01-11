//
//  WXHMovePointView.h
//  Demo
//
//  Created by Jerry on 2018/1/11.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol WXHMovePointViewDelegate <NSObject>

@optional
- (void)pointDidMoveLeftUpPoint:(CGPoint)leftUpPoint
                   rightUpPoint:(CGPoint)rightUpPoint
                leftBottomPoint:(CGPoint)leftBottomPoint
               rightBottomPoint:(CGPoint)rightBottomPoint;
@end
@interface WXHMovePointView : UIView
@property (nonatomic, weak) id<WXHMovePointViewDelegate> delegate;

@property (nonatomic) CGPoint leftUpPoint;
@property (nonatomic) CGPoint rightUpPoint;
@property (nonatomic) CGPoint leftBottomPoint;
@property (nonatomic) CGPoint rightBottomPoint;
@property (nonatomic) CGPoint centerPoint;
@end
