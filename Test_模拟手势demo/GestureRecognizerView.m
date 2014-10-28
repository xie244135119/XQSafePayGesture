//
//  GestureRecognizerView.m
//  Test_模拟手势demo
//
//  Created by SunSet on 13-12-4.
//  Copyright (c) 2013年 SunSet. All rights reserved.
//

#define kArcRadius  32

#import "GestureRecognizerView.h"
#import <QuartzCore/QuartzCore.h>

@interface GestureRecognizerView()
{
    NSArray  *_centerPoints;//9个圆心
    NSMutableArray *_pathCenters;//路径圆心
    CGPoint _movePoint;//移动中的圆心
    
    BOOL _startDraw;//开始绘图
}
@end

@implementation GestureRecognizerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _pathCenters=[[NSMutableArray alloc]init];
    }
    return self;
}
-(void)dealloc
{
    [_pathCenters release];
    _pathCenters=nil;
    
    [_centerPoints release];
    _centerPoints=nil;
    
    NSLog(@"=%@=%@==",self,NSStringFromSelector(_cmd));
    [super dealloc];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context=UIGraphicsGetCurrentContext();
    [self DrawNineArcs:context];
    
    //设置线条颜色
    CGContextSetStrokeColorWithColor(context, [[UIColor brownColor] CGColor]);
    //设置填充色
    CGContextSetFillColorWithColor(context, [[UIColor brownColor] CGColor]);
    
    for (int i=0;i< _pathCenters.count;i++) {
        NSNumber *index=_pathCenters[i];
        CGPoint center=[self currentPoint:(index.intValue-1)];
        //设置圆圈颜色
        CGContextSetLineWidth(context, 4);
        CGContextMoveToPoint(context, center.x+kArcRadius, center.y);
        CGContextAddArc(context,center.x,center.y, kArcRadius,0, M_PI*2, 0);
        CGContextStrokePath(context);
        //设置圆心的填充颜色
        CGContextMoveToPoint(context, center.x, center.y);
        CGContextAddArc(context,center.x,center.y, 10,0, M_PI*2, 0);
        CGContextDrawPath(context, kCGPathFillStroke);
        if (i>0) {
            //起点位置
            NSNumber *index=_pathCenters[i-1];
            CGPoint lastcenter=[self currentPoint:(index.intValue-1)];
            CGContextSetLineWidth(context, 5);
            CGContextMoveToPoint(context, lastcenter.x, lastcenter.y);
            CGContextAddLineToPoint(context, center.x, center.y);
            //每当调用绘画的时候预示结束
            CGContextStrokePath(context);
        }
        //设置最后当前的画笔位置
        CGContextMoveToPoint(context, center.x, center.y);
    }
    
    if ([self indexOfArcsContainPoints:_movePoint]==0&&_startDraw) {
        //如果当前最后的点在圆形里面就不画线了
        CGContextSetLineWidth(context, 5);
        CGContextAddLineToPoint(context, _movePoint.x, _movePoint.y);
        
        CGContextStrokePath(context);
    }
}
/*重新布局*/
-(void)layoutSubviews
{
    self.backgroundColor=[UIColor blackColor];
    UIImage * image=[UIImage imageNamed:@"0.jpg"];
//    image=[self circleImage:image];
    UIImageView *imgView=[[UIImageView alloc]initWithImage:image];
    imgView.frame=CGRectMake(115, 40, 90, 90);
    [self addSubview:imgView];
    imgView.layer.borderColor=[[UIColor whiteColor] CGColor];
    imgView.layer.borderWidth=2;
    imgView.layer.cornerRadius=10;
    imgView.layer.masksToBounds=YES;
    [imgView release];
    
    
    UILabel *lab=[[UILabel alloc]initWithFrame:CGRectMake(0, 100+50, 320, 20)];
    lab.text=@"支付宝提示请先绘制手势";
    lab.textAlignment=UITextAlignmentCenter;
    lab.backgroundColor=[UIColor clearColor];
    lab.textColor=[UIColor whiteColor];
    [self addSubview:lab];
    [lab release];
}

/*判断9个圆是否包含某个点*/
-(NSInteger)indexOfArcsContainPoints:(CGPoint)point
{
    for (int i=0; i<9; i++) {
        CGPoint center=[self currentPoint:i];
        CGFloat distance=sqrt((point.x-center.x)*(point.x-center.x)+(point.y-center.y)*(point.y-center.y));
        if (distance<=kArcRadius) {
            return i+1;
            break;
        }
    }
    return 0;
}

#pragma mark - CustomMethod
/* 绘制9个圆心 */
-(void)DrawNineArcs:(CGContextRef)context
{
    NSMutableArray *centerarry=[NSMutableArray array];
    for (int i=0; i<9; i++) {
        CGPoint center=CGPointMake(70+(64+kArcRadius)*(i%3), 230+(64+kArcRadius)*(i/3));
        [centerarry addObject:[NSValue valueWithCGPoint:center]];
        CGContextMoveToPoint(context, center.x+32, center.y);
        CGContextAddArc(context,center.x,center.y, kArcRadius,0, M_PI*2, 0);
    }
    CGContextSetLineWidth(context, 2);
    CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor]);
    CGContextStrokePath(context);
    
    _centerPoints=[centerarry copy];
}
/*返回某个圆的圆心*/
-(CGPoint)currentPoint:(int)index
{
    NSValue *value=_centerPoints[index];
    return [value CGPointValue];
}

#pragma mark - UITouch事件
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _startDraw=YES;
    
    UITouch *touch=[touches anyObject];
    CGPoint point=[touch locationInView:self];
    int index=[self indexOfArcsContainPoints:point];
    //恢复默认
    _movePoint=point;
    
    if (index>0) {
        if (![_pathCenters containsObject:[NSNumber numberWithInt:index]]) {
            [_pathCenters addObject:[NSNumber numberWithInt:index]];//增加起点
        }
        [self setNeedsDisplay];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch=[touches anyObject];
    CGPoint point=[touch locationInView:self];
    int index=[self indexOfArcsContainPoints:point];
    if (index>0) {
        //清楚之前的线条
        if (![_pathCenters containsObject:[NSNumber numberWithInt:index]]) {
            [_pathCenters addObject:[NSNumber numberWithInt:index]];//增加起点
        }
    }
    _movePoint=point;
    [self setNeedsDisplay];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"==%@",_pathCenters);
    
    if (_pathCenters.count<=4) {
        NSLog(@" 手势密码过短 ");
    }
    
    [self performSelector:@selector(clearStartIndexs) withObject:nil afterDelay:0.5];
}

#pragma mark - 数据处理
/** 清楚之前的痕迹 */
-(void)clearStartIndexs
{
    [_pathCenters removeAllObjects];
    [self setNeedsDisplay];
    
    _startDraw=NO;
}
#pragma mark - 裁剪
-(UIImage *)circleImage:(UIImage *)image
{
    UIGraphicsBeginImageContext(image.size);
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [[UIColor redColor] CGColor]);
    CGContextSetLineWidth(context, 1);
    CGRect rect=CGRectMake(0, 0, image.size.width,image.size.height);
    CGContextAddEllipseInRect(context, rect);
    //以后所有的绘制都在这个框内进行
    CGContextClip(context);
    
    [image drawInRect:rect];
//    CGContextAddEllipseInRect(context, rect);
//    CGContextStrokePath(context);
    //获取新图片
    UIImage * newimage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newimage;
}

@end



