//
//  UIScrollViewExtended.m
//  Palazzo Medici Riccardi
//
//  Created by Evgeniy GT on 8/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIScrollViewExtended.h"


@implementation UIScrollViewExtended

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		//double tap 
		UITapGestureRecognizer *doubleTaprecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapFrom:)];
		[doubleTaprecognizer setNumberOfTapsRequired:2];
		[self addGestureRecognizer:doubleTaprecognizer];
        
        initialSize = self.contentSize;
	}
	return self;
} 

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}

-(void)handleDoubleTapFrom:(UITapGestureRecognizer *)doubleTaprecognizer
{
    //NSLog(@"self.zoomScale = %f", self.zoomScale);
    if (initialSize.height == 0)
    {
        initialSize = self.contentSize;
    }
    
    NSLog(@"frame = %@, bounds = %@", NSStringFromCGRect(self.frame), NSStringFromCGRect(self.bounds));
    NSLog(@"self.contentSize = %@", NSStringFromCGSize(self.contentSize));
    
    CGSize contentSize = self.contentSize;
    
    NSLog(@"contentSize = %@", NSStringFromCGSize(contentSize));
    
	if (self.zoomScale < 1.5)
    {
		[self setZoomScale:1.5 animated:YES];
	}
    else if (self.zoomScale < 3.5)
    {
		[self setZoomScale:3.5 animated:YES];
	}
    else
    {
		[self setZoomScale:self.minimumZoomScale animated:YES];
	}
    
    //NSLog(@"2 self.contentSize = %@", NSStringFromCGSize(self.contentSize));
    //NSLog(@"2 frame = %@, bounds = %@", NSStringFromCGRect(self.frame), NSStringFromCGRect(self.bounds));
    //##TODO mystic there
    
    //[self setContentSize:CGSizeMake(self.bounds.size.width * self.zoomScale, self.bounds.size.height * self.zoomScale)];
    //[self setContentSize:CGSizeMake(initialSize.width * self.zoomScale, initialSize.height * self.zoomScale)];
    
    NSLog(@"3 self.contentSize = %@", NSStringFromCGSize(self.contentSize));
}


@end
