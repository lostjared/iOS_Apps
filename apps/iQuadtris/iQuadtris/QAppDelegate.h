//
//  QAppDelegate.h
//  iQuadtris
//
//  Created by Jared Bruni on 12/12/12.
//  Copyright (c) 2012 Jared Bruni. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QViewController;

@interface QAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) QViewController *viewController;

@end
