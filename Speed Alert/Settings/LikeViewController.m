//
//  LikeViewController.m
//  parkassist
//
//  Created by     on 11/3/13.
//  Copyright (c) 2013 RUHE. All rights reserved.
//

#import "LikeViewController.h"
#import "ViewController.h"

@interface LikeViewController ()

@end

@implementation LikeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationItem.hidesBackButton = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)OnReview:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/park-assist/id732711317?ls=1&mt=8"]];
    ViewController* helpVw = [self.navigationController.viewControllers objectAtIndex:1];
    [self.navigationController popToViewController:helpVw animated:YES];
    [helpVw release];
}

-(IBAction)OnClose:(id)sender
{
    ViewController* helpVw = [self.navigationController.viewControllers objectAtIndex:1];
    [self.navigationController popToViewController:helpVw animated:YES];
    [helpVw release];
}
@end
