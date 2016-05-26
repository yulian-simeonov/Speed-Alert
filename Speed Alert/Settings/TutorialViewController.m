//
//  HelpViewController.m
//  parkassist
//
//  Created by     on 10/27/13.
//  Copyright (c) 2013 RUHE. All rights reserved.
//

#import "TutorialViewController.h"
#import "AppDelegate.h"
#import "ViewController.h"

@implementation TutorialViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        m_bFromHelp = false;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"SetTutorial"] boolValue] && !m_bFromHelp)
    {
        [self ShowMainViewController:NO];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)ShowMainViewController:(BOOL)animation
{
    ViewController* mainVw = (ViewController*)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"sb_main"];
    [self.navigationController pushViewController:mainVw animated:animation];
    [mainVw release];
}

-(void)Back
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)OnClose:(id)sender
{
    if (m_bFromHelp)
        [self Back];
    else
        [self ShowMainViewController:NO];
}
@end
