//
//  GameOver.h
//  iMutatris
//
//  Created by Jared Bruni on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SubGameOver;


@interface GameOver : UIViewController {
    IBOutlet UILabel *g_score;
    UIImage *background_image;
    IBOutlet UIImageView *img_view;
    IBOutlet SubGameOver *game_over;
    int game_score, game_level, game_clears;
}

- (void) setScore: (int) scor Clears: (int) clrz level: (int) level;
- (IBAction) playAgain: (id) sender;
@end


@interface GameOverView : UIView {
   
}

@end



@interface SubGameOver : UIView {
    
}

@end
