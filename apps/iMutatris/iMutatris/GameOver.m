//
//  GameOver.m
//  iMutatris
//
//  Created by Jared Bruni on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameOver.h"
#import "AppDelegate.h"

@implementation GameOver

- (void) playAgain: (id) sender {
    [mainDelegate setNewGame];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [g_score setText:@"Scores"];
    background_image = [UIImage imageNamed:@"scores.png"];
    [img_view setImage:background_image];
    [game_over setBackgroundColor: [UIColor clearColor]];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void) setScore: (int) scor Clears: (int) clrz level: (int) level {
    game_score = scor;
    game_clears = clrz;
    game_level = level;
    NSString *text = [NSString stringWithFormat:@"Score: %d Clears: %d Level: %d", scor, clrz, level];
    [g_score setText:text];
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

@end

@implementation SubGameOver

- (void) drawRect: (CGRect) r {
    
    [[UIColor redColor] set];
    [@"Current High Scores" drawAtPoint: CGPointMake(25,25) withFont:[UIFont systemFontOfSize: 13]];
}

@end

@implementation GameOverView


@end
