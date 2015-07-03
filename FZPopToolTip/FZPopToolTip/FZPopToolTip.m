//
//  FZPopToolTip.m
//  FZPopToolTip
//
//  Created by 周峰 on 15/7/2.
//  Copyright (c) 2015年 MIT. All rights reserved.
//

#import "FZPopToolTip.h"
#import <objc/runtime.h>



@interface UIButton (Action)

-(void) addTouchUpInSideAction:(void(^)()) action;

@end

@implementation UIButton (Action)

-(void) addTouchUpInSideAction:(void (^)())action{
    if (action) {
        objc_setAssociatedObject(self, "touchupinsideAction", action, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self addTarget:self action:@selector(onClick) forControlEvents:UIControlEventTouchUpInside];
    }
}

-(void) onClick{
    id obj= objc_getAssociatedObject(self, "touchupinsideAction");
    ((void(^)())obj)();
}

-(void) dealloc{
    NSLog(@"button dealoc");
}

@end



@interface UIScrollView (UIButton)

@end

@implementation UIScrollView (UIButton)

-(BOOL) touchesShouldCancelInContentView:(UIView *)view{
    return YES;
}

@end


@interface FZPopToolTip ()
@property(strong,nonatomic) NSMutableArray* titleAndActions;

@property(weak,nonatomic) UIView* targetView;

@end
@implementation FZPopToolTip{
    BOOL drawed;
    
    UIGestureRecognizer* tapGr;
    UIGestureRecognizer* swipeGr;
    UIGestureRecognizer* dragGr;
    UIGestureRecognizer* pinchGr;
    
    UIWindow* window;
    UIView* coverView;
}



-(instancetype) init{
    self = [super init];
    _titleAndActions = [NSMutableArray array];
    return self;
}

-(void) dealloc{
    NSLog(@"tooltip dealoc");
}
-(void) addAction:(void(^)()) action forTitle:(NSString*) title{
    [_titleAndActions addObject:@[title,action]];
}


-(void) showOnView:(UIView*) view{
    window = [UIApplication sharedApplication].keyWindow;
    [self drawOnView:view];
    _targetView = view;
    _targetView.userInteractionEnabled = NO;
}

-(void) dismiss{
    [coverView removeFromSuperview];
    [UIView animateWithDuration:.2 animations:^(){
        self.layer.opacity = 0.0;
    } completion:^(BOOL finish){
        self.layer.opacity = 1.0;
        [self removeFromSuperview];
        _targetView.userInteractionEnabled = YES;
    }];
    
    [coverView removeGestureRecognizer:tapGr];
    [coverView removeGestureRecognizer:swipeGr];
    [coverView removeGestureRecognizer:dragGr];
    [coverView removeGestureRecognizer:pinchGr];
    
}

-(void) drawOnView:(UIView*) targetView{
    if(drawed)
        return;
    
    coverView = [[UIView alloc] init];
    coverView.frame = [UIScreen mainScreen].bounds;
    coverView.backgroundColor = [UIColor clearColor];
    [window addSubview:coverView];

    __weak FZPopToolTip* weakSelf = self;
    CGFloat maxWidth = [UIScreen mainScreen].bounds.size.width*0.9;
    CGFloat width = 0.;
    CGFloat height = 0;
    CGFloat textOffset = 10;
    UIScrollView* actionView = [[UIScrollView alloc] init];
    for (NSArray* item in _titleAndActions) {
        NSString* title = item[0];
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        //TEXT
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        [button setTitle:title forState:UIControlStateNormal];
        //SIZE
        [button sizeToFit];
        CGRect frame = button.frame;
        frame.origin = CGPointMake(width, 0);
        frame.size.width += textOffset*2;
        frame.size.height = MAX(35, frame.size.height);
        [button setFrame:frame];
        //BACKGROUND
        [button setBackgroundImage:[self imageWithColor:[UIColor blackColor] andSize:frame.size] forState:UIControlStateNormal];
        UIColor* color = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        [button setBackgroundImage:[self imageWithColor:color andSize:frame.size] forState:UIControlStateHighlighted];
        //addSubview;
        [actionView addSubview:button];
        width += button.frame.size.width+0.5;
        height = MAX(height, button.frame.size.height);
        
        //setAction
        [button addTouchUpInSideAction:^(){
            ((void(^)())item[1])();
            [weakSelf dismiss];
        }];
    }
    
    width -= 0.5;
    
    actionView.frame                   = CGRectMake(0, 0, MIN(maxWidth, width), height);
    actionView.contentSize             = CGSizeMake(width, height);
    actionView.bounces                 = NO;
    actionView.pagingEnabled           = NO;
    actionView.delaysContentTouches    = NO;
    actionView.canCancelContentTouches = YES;
    actionView.backgroundColor         = [UIColor clearColor];
    actionView.layer.cornerRadius      = 5;
    actionView.layer.masksToBounds     = YES;
    [self addSubview:actionView];
    
    
    //箭头三角形
    UIView* triangleView     = [self triangleViewWithColor:[UIColor blackColor]];
    CGRect triangleViewFrame = triangleView.frame;
    triangleViewFrame.origin = CGPointMake(width*0.5-triangleViewFrame.size.width*0.5, height-1);
    triangleView.frame       = triangleViewFrame;
    height                   += triangleViewFrame.size.height;
    [self insertSubview:triangleView atIndex:0];
    
    
    CGFloat _width = MIN(maxWidth, width);
    self.backgroundColor = [UIColor clearColor];
    self.frame = CGRectMake(0, 0, _width, height);
    
    CGPoint targetCenter = [targetView.superview convertPoint:targetView.center toView:nil];
    targetCenter.y -= height;
    
    CGFloat dx = targetCenter.x - _width*0.5-10;
    if (dx < 0) {
        targetCenter.x += -dx;
    }else{
        dx = [UIScreen mainScreen].bounds.size.width - (targetCenter.x+_width*0.5+10);
        if (dx<0) {
            targetCenter.x -= -dx;
        }
    }
    
    
    self.center = targetCenter;
    
    [window addSubview:self];
    
    self.layer.opacity = 0.0;
    [UIView animateWithDuration:.2 animations:^(){
        self.layer.opacity = 1.0;
    }];
    
    [self setWindowGesutre];

}


-(void) setWindowGesutre{
    tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    swipeGr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    dragGr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    pinchGr = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [coverView addGestureRecognizer:tapGr];
    [coverView addGestureRecognizer:swipeGr];
    [coverView addGestureRecognizer:dragGr];
    [coverView addGestureRecognizer:pinchGr];
}



-(void) handleGesture:(UIGestureRecognizer*) gr{
    [self dismiss];
}


- (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size
{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(UIView*) triangleViewWithColor:(UIColor*) color{
    CGFloat width = 15;
    CGSize size = CGSizeMake(width,width*0.5);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //绘制图形
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, size.width, 0);
    CGContextAddLineToPoint(context, size.width*0.5, size.height);
    CGContextClosePath(context);
    
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextDrawPath(context, kCGPathFill);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [[UIImageView alloc] initWithImage:image];
}


@end
