//
//  JTStackControllerAppDelegate.h
//  JTStackController
//
//  Created by Jun on 5/8/11.
//  Copyright 2011 Jun Tanaka. All rights reserved.
//

#import <UIKit/UIKit.h>


@class JTStackController;

@interface JTStackControllerAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet JTStackController *stackController;

- (IBAction)pushNewViewController:(id)sender;
- (IBAction)popViewController:(id)sender;

@end
