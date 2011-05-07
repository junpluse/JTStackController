//
//  JTStackController.h
//  JTStackController
//
//  Created by Jun on 5/8/11.
//  Copyright 2011 Jun Tanaka. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol JTStackControllerDelegate;

@interface JTStackController : UIViewController {
    @package
    UIScrollView   *_containerView;
    NSMutableArray *_viewControllers;
    BOOL            _animationInProgress;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController;

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;

- (UIViewController *)popViewControllerAnimated:(BOOL)animated;
- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated;

@property (nonatomic, readonly) UIViewController *topViewController;
@property (nonatomic, readonly) UIViewController *visibleViewController;

@property (nonatomic, copy) NSArray *viewControllers; 
- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated;

@property (nonatomic) UIEdgeInsets containerInsets;

@property (nonatomic, assign) IBOutlet id <JTStackControllerDelegate> delegate;

@end


@protocol JTStackControllerDelegate <NSObject>
@optional
- (void)stackController:(JTStackController *)stackController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)stackController:(JTStackController *)stackController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)stackController:(JTStackController *)stackController willDismissViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)stackController:(JTStackController *)stackController didDismissViewController:(UIViewController *)viewController animated:(BOOL)animated;

@end
