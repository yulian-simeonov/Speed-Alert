//
//  ViewController.h
//  Speed Alert
//
//  Created by     on 11/8/13.
//  Copyright (c) 2013 michael. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "JSWebManager.h"
#import <MapKit/MapKit.h>
#import "SlideMenu.h"
#import "TutorialViewController.h"

#define kRequiredAccuracy 500.0 //meters
#define kMaxAge 10.0 //seconds
#define M_PI   3.14159265358979323846264338327950288   /* pi */

@interface ViewController : UIViewController<CLLocationManagerDelegate,UINavigationControllerDelegate, UIScrollViewDelegate>
{
    IBOutlet UIScrollView* m_scrollView;
    IBOutlet UIPageControl* m_pageCtrl;
    IBOutlet MKMapView* _mapView;
    IBOutlet UILabel* lbl_curSpeed;
    IBOutlet UILabel* lbl_limitSpeed;
    
    IBOutlet UIView* vw_main;
    SlideMenu* slideMenu;
    BOOL m_shownMenu;
    
    CLLocationSpeed m_curSpeed;
    CLLocationSpeed m_limiteSpeed;
    CLLocationCoordinate2D m_curPos;
    CLLocationDirection m_curDirect;
    MKUserLocation* m_userPin;
    NSTimer *timer;
    NSDate*     m_prevTime;
    JSWebManager* m_webMgr;
}
-(IBAction)OnMenu:(id)sender;
-(void)ChangeView:(int)idx;
@end
