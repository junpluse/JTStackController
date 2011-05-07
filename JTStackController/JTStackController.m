//
//  JTStackController.m
//  JTStackController
//
//  Created by Jun on 5/8/11.
//  Copyright 2011 Jun Tanaka. All rights reserved.
//

#import "JTStackController.h"
#import <QuartzCore/QuartzCore.h>


#pragma mark -
@interface JTStackControllerContainerView : UIScrollView {    
}

@end


#pragma mark -
@implementation JTStackControllerContainerView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    return [self.superview pointInside:[self.superview convertPoint:point fromView:self] withEvent:event];
}

@end


#pragma mark -
@interface JTStackController (Private) <UIScrollViewDelegate>

- (void)sharedInit;
- (void)layoutViews;
- (void)showViewController:(UIViewController *)viewController;
- (void)dismissViewControlller:(UIViewController *)viewController;
- (void)dropViewController:(UIViewController *)viewController;
- (void)dropViewControllersBelowBounds;

@end


#pragma mark -
@implementation JTStackController

@synthesize delegate        = _delegate;
@synthesize containerInsets = _containerInsets;

- (void)dealloc
{
    [self setViewControllers:nil];
    [_viewControllers release], _viewControllers = nil;
    
    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self sharedInit];
    }
    return self;
}


#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (void)loadView
{
    UIView *rootView = [[UIView alloc] init];
    
    _containerView = [[JTStackControllerContainerView alloc] initWithFrame:rootView.bounds];
    _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _containerView.clipsToBounds = NO;
    _containerView.delegate = self;
    _containerView.pagingEnabled = YES;
    _containerView.directionalLockEnabled = YES;
    _containerView.bounces = YES;
    _containerView.alwaysBounceHorizontal = NO;
    _containerView.alwaysBounceVertical = YES;
    _containerView.showsHorizontalScrollIndicator = NO;
    _containerView.showsVerticalScrollIndicator = NO;
    
    // observe frame updates
    [_containerView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    [rootView addSubview:_containerView];
    
    self.view = rootView;
}

- (void)viewDidLoad
{    
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [_containerView release], _containerView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setContainerInsets:_containerInsets];
    [self scrollViewDidScroll:_containerView];
}

- (void)viewDidAppear:(BOOL)animated
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    [self layoutViews];
}


#pragma mark - JTStackController (Private)

- (void)sharedInit
{
    _viewControllers = [[NSMutableArray alloc] init];
    _containerInsets = UIEdgeInsetsZero;
    _animationInProgress = NO;
}

- (void)layoutViews
{
    // update content size
    CGSize contentSize = CGSizeMake(_containerView.bounds.size.width, _containerView.bounds.size.height * [_viewControllers count]);
    _containerView.contentSize = contentSize;
    
    // update view sizes
    for (UIViewController *viewController in _viewControllers) {
        viewController.view.frame = CGRectMake(0, _containerView.bounds.size.height * [_viewControllers indexOfObject:viewController], _containerView.bounds.size.width, _containerView.bounds.size.height);
    }
    
    // scroll to top view controller
    [_containerView scrollRectToVisible:[self topViewController].view.frame animated:NO];
    [self scrollViewDidScroll:_containerView];
}

- (void)showViewController:(UIViewController *)viewController
{
    if (viewController.view.superview) {
        return;
    }
    
    // call delegate #1
    if (self.delegate && [self.delegate respondsToSelector:@selector(stackController:willShowViewController:animated:)]) {
        [self.delegate stackController:self willShowViewController:viewController animated:_animationInProgress];
    }
    
    // add view
    [viewController viewWillAppear:_animationInProgress];
    [_containerView insertSubview:viewController.view atIndex:1];
    [viewController viewDidAppear:_animationInProgress];
    
    // call delegate #2
    if (self.delegate && [self.delegate respondsToSelector:@selector(stackController:didShowViewController:animated:)]) {
        [self.delegate stackController:self didShowViewController:viewController animated:_animationInProgress];
    }
}

- (void)dismissViewControlller:(UIViewController *)viewController
{
    if (!viewController.view.superview) {
        return;
    }
    
    // call delegate #1
    if (self.delegate && [self.delegate respondsToSelector:@selector(stackController:willDismissViewController:animated:)]) {
        [self.delegate stackController:self willDismissViewController:viewController animated:_animationInProgress];
    }
    
    // remove view
    [viewController viewWillDisappear:_animationInProgress];
    [viewController.view removeFromSuperview];
    [viewController viewDidDisappear:_animationInProgress];
    
    // call delegate #2
    if (self.delegate && [self.delegate respondsToSelector:@selector(stackController:didDismissViewController:animated:)]) {
        [self.delegate stackController:self didDismissViewController:viewController animated:_animationInProgress];
    }
}

- (void)dropViewController:(UIViewController *)viewController
{
    // dismiss view controller
    [self dismissViewControlller:viewController];
    
    // remove from array
    [_viewControllers removeObject:viewController];
    
    // resize content size
    CGSize contentSize = _containerView.contentSize;
    contentSize.height -= _containerView.bounds.size.height;
    _containerView.contentSize = contentSize;
}

- (void)dropViewControllersBelowBounds
{
    for (UIViewController *viewController in [_viewControllers reverseObjectEnumerator]) {
        if (CGRectGetMaxY(_containerView.bounds) <= CGRectGetMinY(viewController.view.frame)) {
            [self dropViewController:viewController];
        }
    }
}


#pragma mark - JTStackController (Public)

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        [_viewControllers addObject:rootViewController];
    }
    return self;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (!viewController) {
        return;
    }
    
    // update content size
    CGSize contentSize = _containerView.contentSize;
    contentSize.height += _containerView.bounds.size.height;
    _containerView.contentSize = contentSize;
    
    // update view frame
    viewController.view.frame = CGRectMake(0, _containerView.bounds.size.height * [_viewControllers count], _containerView.bounds.size.width, _containerView.bounds.size.height);
    
    // add controller to array
    [_viewControllers addObject:viewController];
    
    if (animated) {
        _animationInProgress = YES;
    }
    
    // scroll to view
    [_containerView scrollRectToVisible:viewController.view.frame animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    if ([_viewControllers count] <= 1) {
        return nil;
    }
    
    // retain top view controller
    UIViewController *topViewController = [[self topViewController] retain];
    
    if (animated) {
        _animationInProgress = YES;
    }
    
    // scroll to previous view controller
    UIViewController *previousViewController = [_viewControllers objectAtIndex:[_viewControllers count] - 2];
    [_containerView scrollRectToVisible:previousViewController.view.frame animated:animated];
    
    if (!animated) {
        [self dropViewControllersBelowBounds];
    }
    
    return [topViewController autorelease];
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (![_viewControllers containsObject:viewController]) {
        return nil;
    }
    
    NSMutableArray *viewControllers = [NSMutableArray array];
    while ([self topViewController] != viewController) {
        [viewControllers addObject:[self popViewControllerAnimated:animated]];
    }
    return viewControllers;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
    return [self popToViewController:[_viewControllers objectAtIndex:0] animated:animated];
}

- (UIViewController *)topViewController
{
    return [_viewControllers lastObject];
}

- (UIViewController *)visibleViewController
{
    UIViewController *topViewController = [self topViewController];
    
    // if controller has modal view controller, return it
    if ([topViewController modalViewController]) {
        return [topViewController modalViewController];
    }
    
    return topViewController;
}

- (NSArray *)viewControllers
{
    return _viewControllers;
}

- (void)setViewControllers:(NSArray *)viewControllers
{
    [self setViewControllers:viewControllers animated:NO];
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated
{
    [self popToRootViewControllerAnimated:animated];
    [self dropViewController:[self topViewController]];
    
    for (UIViewController *viewController in viewControllers) {
        [self pushViewController:viewController animated:animated];
    }
}

- (void)setContainerInsets:(UIEdgeInsets)containerInsets
{
    _containerInsets = containerInsets;
    _containerView.frame = UIEdgeInsetsInsetRect(self.view.bounds, containerInsets);
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{    
    UIEdgeInsets visibleInsets = UIEdgeInsetsMake(-_containerInsets.top, -_containerInsets.left, -_containerInsets.bottom, -_containerInsets.right);
    CGRect visibleRect = CGRectStandardize(UIEdgeInsetsInsetRect(scrollView.bounds, visibleInsets));
    
    for (UIViewController *viewController in [_viewControllers reverseObjectEnumerator]) {
        
        // if controller's view is in visible rect
        if (CGRectIntersectsRect(visibleRect, viewController.view.frame)) {
            
            // show view controller
            [self showViewController:viewController];
            
            // enable/disable interaction
            viewController.view.userInteractionEnabled = CGRectContainsRect(scrollView.bounds, viewController.view.frame);
            
            // fading
            if (viewController != [_viewControllers objectAtIndex:0] && scrollView.bounds.origin.y < viewController.view.frame.origin.y) {
                viewController.view.alpha = CGRectIntersection(scrollView.bounds, viewController.view.frame).size.height / viewController.view.frame.size.height;;
            }
            else {
                viewController.view.alpha = 1.0;
            }
        }
        else {
            // dismiss view controller
            [self dismissViewControlller:viewController];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (decelerate) {
        _animationInProgress = YES;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollViewDidEndScrollingAnimation:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    _animationInProgress = NO;
    [self dropViewControllersBelowBounds];
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    _animationInProgress = YES;
    return YES;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    [self scrollViewDidEndScrollingAnimation:scrollView];
}


#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // if container frame changed
    if (object == _containerView && [keyPath isEqualToString:@"frame"]) {
        CGRect oldFrame = [[change objectForKey:NSKeyValueChangeOldKey] CGRectValue];
        CGRect newFrame = [[change objectForKey:NSKeyValueChangeNewKey] CGRectValue];
        
        // if new frame size is not equal to old frame size
        if (!CGSizeEqualToSize(oldFrame.size, newFrame.size)) {
            [self layoutViews];
        }
    }
}


@end
