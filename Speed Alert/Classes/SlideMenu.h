//
//  SlideMenu.h
//  CCTVTools
//
//  Created by     on 11/1/13.
//  Copyright (c) 2013 AUCOM Surveillance. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  ViewController;

@interface SlideMenu : UIView<UITableViewDataSource, UITableViewDelegate>
{
    NSString* menus[6];
    IBOutlet UITableView* tbl_menu;
@public
    ViewController* m_parent;
}
-(void)initWithData:(ViewController*)parent;
@end
