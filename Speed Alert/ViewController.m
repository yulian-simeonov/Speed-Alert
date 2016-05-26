//
//  ViewController.m
//  Speed Alert
//
//  Created by     on 11/8/13.
//  Copyright (c) 2013 michael. All rights reserved.
//

#import "ViewController.h"
#import "XMLReader.h"
#import "SpeedSign.h"
#import "AppDelegate.h"

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"SetTutorial"];
    [NSUserDefaults resetStandardUserDefaults];
    
    CLLocationManager *locationManager=[[CLLocationManager alloc] init];
    locationManager.delegate=self;
    locationManager.desiredAccuracy=kCLLocationAccuracyBestForNavigation;
    [locationManager startUpdatingLocation];
    
    m_webMgr = [[JSWebManager alloc] initWithAsyncOption:YES];
    [m_webMgr setDelegate:self];
    m_curSpeed = 0;
    m_limiteSpeed = 0;
    
    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(GetSpeedSigns) userInfo:nil repeats:NO];
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(UpdateSpeed) userInfo:nil repeats:YES];
    
    [m_scrollView setContentSize:CGSizeMake(m_scrollView.contentSize.width * 2, m_scrollView.contentSize.height)];
    
    NSArray* xib = [[NSBundle mainBundle] loadNibNamed:@"SlideMenu" owner:self options:nil];
    slideMenu = (SlideMenu*)[xib objectAtIndex:0];
    [slideMenu initWithData:self];
    [slideMenu setFrame:CGRectMake(-slideMenu.frame.size.width, 0, slideMenu.frame.size.width, slideMenu.frame.size.height)];
    [self.view addSubview:slideMenu];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    m_curPos = newLocation.coordinate;
    m_curDirect = newLocation.course;
    if(newLocation && oldLocation)
    {
        if (m_prevTime)
        {
            NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:m_prevTime];
            float dist = [self getDistanceInKm:newLocation fromLocation:oldLocation];
            if (dist != 0)
                m_curSpeed = dist / interval * 3600;
            [m_prevTime release];
        }
        m_prevTime = [[NSDate date] retain];
    }
}

- (void)UpdateSpeed
{
    if (m_curSpeed > 1000)
        return;
    [lbl_curSpeed setText:[NSString stringWithFormat:@"%.2f", m_curSpeed]];
    [lbl_limitSpeed setText:[NSString stringWithFormat:@"%d", (int)m_limiteSpeed]];
}

-(float)getDistanceInKm:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    float lat1,lon1,lat2,lon2;
    
    lat1 = newLocation.coordinate.latitude  * M_PI / 180;
    lon1 = newLocation.coordinate.longitude * M_PI / 180;
    
    lat2 = oldLocation.coordinate.latitude  * M_PI / 180;
    lon2 = oldLocation.coordinate.longitude * M_PI / 180;
    
    float R = 6371; // km
    float dLat = lat2-lat1;
    float dLon = lon2-lon1;
    
    float a = sin(dLat/2) * sin(dLat/2) + cos(lat1) * cos(lat2) * sin(dLon/2) * sin(dLon/2);
    float c = 2 * atan2(sqrt(a), sqrt(1-a));
    float d = R * c;
    return d;
}

-(float)getDistanceInMiles:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    float lat1,lon1,lat2,lon2;
    
    lat1 = newLocation.coordinate.latitude  * M_PI / 180;
    lon1 = newLocation.coordinate.longitude * M_PI / 180;
    
    lat2 = oldLocation.coordinate.latitude  * M_PI / 180;
    lon2 = oldLocation.coordinate.longitude * M_PI / 180;
    
    float R = 3963; // km
    float dLat = lat2-lat1;
    float dLon = lon2-lon1;
    
    float a = sin(dLat/2) * sin(dLat/2) + cos(lat1) * cos(lat2) * sin(dLon/2) * sin(dLon/2);
    float c = 2 * atan2(sqrt(a), sqrt(1-a));
    float d = R * c;
    return d;
}

-(void)GetSpeedSigns
{
    [m_webMgr GetSpeedSigns:m_curPos.latitude longtitude:m_curPos.longitude];
}

-(void)WebManagerFailed:(NSError*)error
{
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(GetSpeedSigns) userInfo:nil repeats:NO];
}

-(void)ReceivedValue:(ASIHTTPRequest*)req
{
    if (req.responseData)
    {
        [APP->m_signs removeAllObjects];
        NSError* error;
        NSArray* ary = [[[XMLReader dictionaryForXMLData:req.responseData error:&error] valueForKey:@"markers"] objectForKey:@"marker"];
        for(NSDictionary* dic in ary)
        {
            if (![dic isKindOfClass:[NSDictionary class]])
                continue;
            SpeedSign* sign = [[SpeedSign alloc] initWithDictionary:dic];
            [APP->m_signs addObject:sign];
            [sign release];
        }
        [self GetSpeedLimit];
    }
    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(GetSpeedSigns) userInfo:nil repeats:NO];
}

-(void)GetSpeedLimit
{
    if (m_curDirect < 0)
        return;
    
    NSMutableArray* availableSigns = [[NSMutableArray alloc] init];
    for (SpeedSign* sign in APP->m_signs)
    {
        if (m_curDirect <= 45 || m_curDirect > 315)
        {
            if(sign.Latitude <= m_curPos.latitude)
                [availableSigns addObject:sign];
        }
        else if (m_curDirect > 45 && m_curDirect <= 135)
        {
            if (sign.Longitude <= m_curPos.longitude)
                [availableSigns addObject:sign];
        }
        else if (m_curDirect > 135 && m_curDirect <= 225)
        {
            if (sign.Latitude >= m_curPos.latitude)
                [availableSigns addObject:sign];
        }
        else
        {
            if (sign.Longitude >= m_curPos.longitude)
                [availableSigns addObject:sign];
        }
    }
    
    CLLocationDistance minDist = CLLocationDistanceMax;
    SpeedSign* bestSign = nil;
    for(SpeedSign* sign in availableSigns)
    {
        float diff = ABS(sign.Latitude - m_curPos.latitude) + ABS(sign.Longitude - m_curPos.longitude);
        if (diff < minDist && [self GetAngleDiff:m_curDirect secondAngle:sign.Bearing] < 45)
        {
            minDist = diff;
            bestSign = sign;
        }
    }
    
    if (bestSign)
    {
        if (bestSign.Mph != 0)
            m_limiteSpeed = 1.609344f * bestSign.Mph;
        else if (bestSign.Kph != 0)
            m_limiteSpeed = bestSign.Kph;
    }
    
    [self UpdateMap];
    
    [availableSigns release];
}

-(float)GetAngleDiff:(float)agl1 secondAngle:(float)agl2
{
    float cogByTwo_x = agl1 / 2;
    float cogByTwo = agl2 / 2;
    float i16;
    if (cogByTwo_x >= cogByTwo)
        i16 = cogByTwo_x - cogByTwo;
    else
        i16 = cogByTwo - cogByTwo_x;
    
    if (i16 > 90.0f)
        i16 = ABS(180 - i16);
    return i16 * 2;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger pageIndex = round(scrollView.contentOffset.x / scrollView.bounds.size.width);
    if (m_pageCtrl.currentPage != pageIndex)
        m_pageCtrl.currentPage = pageIndex;
}

-(void)UpdateMap
{
//    MKCoordinateRegion region;
//    MKCoordinateSpan span;
//    span.latitudeDelta=0.002f;
//    span.longitudeDelta=0.002f;
//    region.span = span;
//    region.center = m_userPin.coordinate;
//    [_mapView setRegion:region animated:TRUE];
//    [_mapView regionThatFits:region];
    
    [_mapView removeAnnotations:_mapView.annotations];
    for(SpeedSign* sign in APP->m_signs)
    {
        MKPointAnnotation* pin = [[[MKPointAnnotation alloc] init] autorelease];
        pin.title = sign.Text;
        pin.coordinate = CLLocationCoordinate2DMake(sign.Latitude, sign.Longitude);
        [_mapView addAnnotation:pin];
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    m_userPin = userLocation;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation
{
//    if (![annotation isKindOfClass:[MKUserLocation class]])
//    {
//        MKAnnotationView *annotationView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"carAnnotationViewID"];
//        if (annotationView == nil)
//            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"carAnnotationViewID"];
//        annotationView.image = [UIImage imageNamed:@"marker.png"];
//        annotationView.annotation = annotation;
//        annotationView.canShowCallout = true;
//        return annotationView;
//    }
//    else
        return nil;
}

-(IBAction)OnNextPreview:(id)sender
{
    if (((UIButton*)sender).tag == 0)
        [m_scrollView setContentOffset:CGPointMake(m_scrollView.contentOffset.x - 320, 0)];
    else
        [m_scrollView setContentOffset:CGPointMake(m_scrollView.contentOffset.x + 320, 0)];
}

-(IBAction)OnMenu:(id)sender
{
    [ UIView beginAnimations:nil context:vw_main];
    [ UIView beginAnimations:nil context:slideMenu];
    [ UIView setAnimationDelegate: self ];
    [ UIView setAnimationDuration:0.3f ];
    if (m_shownMenu)
    {
        vw_main.frame = CGRectMake(0, 0, vw_main.frame.size.width, vw_main.frame.size.height);
        slideMenu.frame = CGRectMake(-slideMenu.frame.size.width, 0, slideMenu.frame.size.width, slideMenu.frame.size.height);
        m_shownMenu = false;
    }
    else
    {
        vw_main.frame = CGRectMake(slideMenu.frame.size.width, 0, vw_main.frame.size.width, vw_main.frame.size.height);
        slideMenu.frame = CGRectMake(0, 0, slideMenu.frame.size.width, slideMenu.frame.size.height);
        m_shownMenu = true;
    }
    [UIView commitAnimations];
}

-(void)ChangeView:(int)idx
{
    switch (idx) {
        case 0:
            [self.navigationController pushViewController:[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"sb_about"] animated:YES];
			break;
		case 1:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/speed-alert/id737304929?ls=1&mt=8"]];
			break;
		case 2:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.trackometer.net"]];
			break;
		case 3:
            self.navigationController.navigationBarHidden = YES;
            TutorialViewController* tutVw = (TutorialViewController*)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"sb_tutorial"];
            tutVw->m_bFromHelp = YES;
            [self.navigationController pushViewController:tutVw animated:YES];
			break;
		case 4:
            [self.navigationController pushViewController:[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"sb_suggestion"] animated:YES];
			break;
		default:
			break;
	}
}
@end
