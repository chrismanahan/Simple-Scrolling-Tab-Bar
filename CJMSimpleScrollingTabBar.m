//
//  CJMSimpleScrollingTabBar.m
//
//  Created by Christopher Manahan on 11/26/14.
//  Copyright (c) Christopher Manahan. All rights reserved.
//

#import "CJMSimpleScrollingTabBar.h"

/**
 *  The number of buttons to display on the tab bar before the user needs to scroll. If you exceed 4 or 5, the title labels might start to get squished and truncated
 */
const CGFloat kCJMTabBarMaxButtonsOnScreen = 4;

/**
 *  Index of button that should be the first selected. If this value is out of range, the first view is selected
 */
const NSInteger kCJMTabBarInitialButtonIndex = 8;

#pragma mark - Tab Bar Button
@interface _CJMTabBarButton : UIButton

/**
 *  Color of button image and text when active
 */
@property (nonatomic, strong) UIColor *highlightColor;
/**
 *  Color of button image and text when not selected
 */
@property (nonatomic, strong) UIColor *passiveColor;
/**
 *  Active is when a button is currently selected and the related view controller is showing
 */
@property (nonatomic, assign, getter=isActive) BOOL active;

/**
 *  Image view that holds the tab bar image
 */
@property (nonatomic, strong) UIImageView *imageView;
/**
 *  Image pulled from original UITabBarItem to be shown in the button
 */
@property (nonatomic, strong) UIImage *image;

@end

#pragma mark - Tab Bar Controller
@interface CJMSimpleScrollingTabBar ()

/**
 *  Houses the tab bar buttons
 */
@property (nonatomic, strong) UIScrollView *scrollView;
/**
 *  Buttons in scrolling tab bar
 */
@property (nonatomic, strong) NSArray *tabBarButtons;

@end

@implementation CJMSimpleScrollingTabBar

#pragma mark - View Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // CHANGE THIS: This color is the background color of your tab bar
    self.tabBar.barTintColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    
    // CHANGE THIS: This color is the color of you tab bar icon and title when it is selected.
    self.tabBar.tintColor = [UIColor blueColor];
    
    // set up scroll view
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tabBar.frame), CGRectGetHeight(self.tabBar.frame))];
    _scrollView.backgroundColor = self.tabBar.barTintColor;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.bounces = NO;
    _scrollView.pagingEnabled = YES;
    
    // set up buttons
    NSInteger numberOfButtons = self.tabBar.items.count;
    NSInteger buttonHeight = CGRectGetHeight(self.tabBar.frame) - 2;
    NSInteger buttonWidth;
    
    // determine button width
    if (numberOfButtons > kCJMTabBarMaxButtonsOnScreen)
    {
        buttonWidth = CGRectGetWidth(_scrollView.frame) / kCJMTabBarMaxButtonsOnScreen;
    }
    else
    {
        buttonWidth = CGRectGetWidth(_scrollView.frame) / numberOfButtons;
    }
    
    NSInteger x = 0;
    
    _CJMTabBarButton *initialButton;
    NSMutableArray *buttons = [[NSMutableArray alloc] initWithCapacity:numberOfButtons];
    for (int i = 0; i < numberOfButtons; i++)
    {
        UITabBarItem *item = self.tabBar.items[i];
        
        _CJMTabBarButton *btn = [[_CJMTabBarButton alloc] initWithFrame:CGRectMake(x, 5, buttonWidth, buttonHeight)];
        btn.highlightColor = self.tabBar.tintColor;
        
        [btn setTitle:item.title forState:UIControlStateNormal];
        btn.image = item.selectedImage;
        
        // set tag so we know which button this is
        btn.tag = i;
        
        [btn addTarget:self action:@selector(didTapButton:) forControlEvents:UIControlEventTouchUpInside];

        [_scrollView addSubview:btn];
        
        x += buttonWidth;
        
        // add to temp arr
        [buttons addObject:btn];
        
        
        // activate initial button
        if (i == kCJMTabBarInitialButtonIndex)
        {
            initialButton = btn;
        }
    }
    
    // keep refs to all buttons
    _tabBarButtons = [[NSArray alloc] initWithArray:buttons];
    
    // add scroll view to tab bar
    [self.tabBar addSubview:_scrollView];
    
    // set content size to fit all buttons
    _scrollView.contentSize = CGSizeMake(x, buttonHeight);
    
    if (initialButton)
    {
        [self didTapButton:initialButton];
    }
    else
    {
        // select first button by default
        [self didTapButton:_tabBarButtons[0]];
    }
}

#pragma mark - actions
- (void)didTapButton:(UIButton*)sender
{
    NSInteger tag = sender.tag;

    // only change vc if we're selecting a different tab
    if (self.selectedIndex != tag)
    {
        self.selectedIndex = tag;
        
        if (self.selectedViewController.navigationController)
        {
            // we need to hide the navigation bar if the vc is part of the 'more' tab
            self.selectedViewController.navigationController.navigationBarHidden = YES;
        }
        
        // we gotta put the scroll view back on top because the more icon likes to appear on top once you click a vc that belongs in there
        [_scrollView removeFromSuperview];
        [self.tabBar insertSubview:_scrollView atIndex:self.tabBar.subviews.count];
        
        // adjust the view's frame. it was expanding underneath the tab bar when we switched to it
        CGRect frame = self.selectedViewController.view.frame;
        frame.size.height -= CGRectGetHeight(self.tabBar.frame);
        self.selectedViewController.view.frame = frame;
        
        // update buttons
        for (_CJMTabBarButton *button in _tabBarButtons)
        {
            button.active = NO;
        }
        _CJMTabBarButton *button = _tabBarButtons[tag];
        button.active = YES;
    }
}

@end

#pragma mark - Tab Bar Button Implementation
@implementation _CJMTabBarButton

@synthesize imageView = _imageView;

#pragma mark - Init
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _passiveColor = [UIColor colorWithWhite:0.6 alpha:1.0];
        
        // set title
        self.titleLabel.font = [UIFont fontWithName:@"Avenir" size:12.0f];
        [self setTitleColor:_passiveColor forState:UIControlStateNormal];
        // align to bottom
        [self setContentVerticalAlignment:UIControlContentVerticalAlignmentBottom];
        
        _imageView = [[UIImageView alloc] init];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        CGFloat padding = 2.0;
        [self addConstraints:@[[NSLayoutConstraint constraintWithItem:_imageView
                                                            attribute:NSLayoutAttributeCenterX
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeCenterX
                                                           multiplier:1.0
                                                             constant:padding],
                               [NSLayoutConstraint constraintWithItem:_imageView
                                                            attribute:NSLayoutAttributeTop
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeTop
                                                           multiplier:1.0
                                                             constant:0],
                               [NSLayoutConstraint constraintWithItem:_imageView
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeHeight
                                                           multiplier:1.0
                                                             constant: 30]]];
        
        [self addSubview:_imageView];
    }
    return self;
}

#pragma mark - Properties
- (void)setImage:(UIImage *)image
{
    _image = image;
    _imageView.image = _image;
}

- (void)setActive:(BOOL)active
{
    _active = active;
    
    if (_active)
    {
        [self setTitleColor:_highlightColor forState:UIControlStateNormal];
        self.imageView.image = [self _changeImage:_image color:_highlightColor];
    }
    else
    {
        [self setTitleColor:_passiveColor forState:UIControlStateNormal];
        self.imageView.image = [self _changeImage:_image color:_passiveColor];
    }
}

#pragma mark - Private
- (UIImage*)_changeImage:(UIImage*)image color:(UIColor*)color
{
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, image.scale);
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    [image drawInRect:rect];
    
    CGContextSetFillColorWithColor(c, [color CGColor]);
    CGContextSetBlendMode(c, kCGBlendModeSourceAtop);
    
    CGContextFillRect(c, rect);
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

@end

