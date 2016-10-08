//
//  StartScreen.m
//  iMutatris
//
//  Created by Jared Bruni on 4/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StartScreen.h"
#import "AppDelegate.h"

@implementation StartScreen
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
   
    UIImage *im = [UIImage imageNamed:@"start.png"];
    [bg_image setImage:im];
    UIImage *im2 = [UIImage imageNamed:@"background.jpg"];
    [logo_img setImage:im2];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction) openWindow: (id) sender {
    [mainDelegate setNewGame];
}

@end

@implementation StartView

@end

@implementation StartViewNested

- (void) drawRect: (CGRect) rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect bounds = [self bounds];
    
    CGContextSetRGBFillColor(context, 0, 0, 0, 1);
    CGContextFillRect(context, bounds);

    [[UIColor redColor] set];
    [@"Mutatris for iOS" drawAtPoint: CGPointMake(5,10) withFont: [UIFont systemFontOfSize: 16]];
    
    
}

@end