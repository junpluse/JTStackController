//
//  JTStackControllerAppDelegate.m
//  JTStackController
//
//  Created by Jun on 5/8/11.
//  Copyright 2011 Jun Tanaka. All rights reserved.
//

#import "JTStackControllerAppDelegate.h"
#import "JTStackController.h"
#import "DemoViewController.h"


#pragma mark -
@implementation JTStackControllerAppDelegate

@synthesize window = _window;
@synthesize stackController = _stackController;

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (UIViewController *)_newDemoViewController
{
    static NSUInteger count = 0;
    
    DemoViewController *viewController = [[[DemoViewController alloc] init] autorelease];
    viewController.view.backgroundColor = [UIColor colorWithHue:1.0 / 7 * (count % 7) saturation:1.0 brightness:1.0 alpha:1.0];
    viewController.label.text = [NSString stringWithFormat:@"#%u", count];
    count ++;
    
    return viewController;
}

- (IBAction)pushNewViewController:(id)sender
{
    UIViewController *newViewController = [[[self _newDemoViewController] retain] autorelease];
    [self.stackController pushViewController:newViewController animated:YES];
}

- (IBAction)popViewController:(id)sender
{
    [self.stackController popViewControllerAnimated:YES];
}


#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    self.stackController.containerInsets = UIEdgeInsetsMake(80, 40, 80, 40);
    
    [self pushNewViewController:nil];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
