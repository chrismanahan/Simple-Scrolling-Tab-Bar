# Simple-Scrolling-Tab-Bar
This is an implementation of UITabBarController that lets you easily add tabs using your storyboard and creates a scrolling tab bar with minimal configuration.

### How to use? Like this!
1. In your storyboard, use a `UITabBarController` as your root view and connect all your child view controllers to it as you normally would
2. Change the class of that `UITabBarController` to `CJMSimpleScrollingTabBar`
3. Configure your new tab bar controller with a few changes in `CJMSimpleScrollingTabBar.m`

### What to configure:
 * Constants you can leave or change, located at the top of `CJMSimpleScrollingTabBar.m`
 ```objective-c
const CGFloat kCJMTabBarMaxButtonsOnScreen = 4;
const NSInteger kCJMTabBarInitialButtonIndex = 0;
```
   * `kCJMTabBarMaxButtonsOnScreen` is the number of buttons that will be display on the screen before the user needs to scroll
   * `kCJMTabBarInitialButtonIndex` is the first button that will be selected when the controller is loaded

 * Things you should change
 ```objective-c
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tabBar.barTintColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    self.tabBar.tintColor = [UIColor blueColor];
    ....
    }
 ```
   * `barTintColor` controls the background color of your tab bar
   * `tintColor` controls the color of the active button, just like the standard tab bar controller
   
 
That's it! Nothing else you need to do. Report issues if you run into any :)