//
//  StartScreen.h
//  iMutatris
//
//  Created by Jared Bruni on 4/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StartScreen : UIViewController {
    IBOutlet UIImageView *bg_image, *logo_img;
    
}

- (IBAction) openWindow: (id) sender;

@end

@interface StartView : UIView {
    

}
@end

@interface StartViewNested : UIView {
    
}
@end