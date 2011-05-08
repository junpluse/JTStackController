//
//  DemoViewController.m
//  JTStackController
//
//  Created by Jun on 5/8/11.
//  Copyright 2011 Jun Tanaka. All rights reserved.
//

#import "DemoViewController.h"


@implementation DemoViewController

@synthesize label = _label;

- (void)loadView
{
    self.view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)] autorelease];
    
    self.label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 40)] autorelease];
    self.label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.label.center = self.view.center;
    self.label.backgroundColor = [UIColor clearColor];
    self.label.textAlignment = UITextAlignmentCenter;
    self.label.textColor = [UIColor whiteColor];
    self.label.font = [UIFont fontWithName:@"Helvetica-Bold" size:32.0];
    
    [self.view addSubview:self.label];
}

- (void)viewDidUnload
{
    self.label = nil;
}

@end
