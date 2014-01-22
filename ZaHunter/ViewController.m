//
//  ViewController.m
//  ZaHunter
//
//  Created by Sonam Mehta on 1/22/14.
//  Copyright (c) 2014 Sonam Mehta. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface ViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource>
{
    CLLocation *currentLocation;
    CLLocationManager *locationManager;
    NSMutableArray *arrayWithPlacemarks;
    
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    arrayWithPlacemarks = [NSMutableArray new];
    
    [locationManager setDistanceFilter:kCLDistanceFilterNone];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    
    [locationManager startUpdatingLocation];
    
    
    CLLocationCoordinate2D PIZZACOORDINATE = CLLocationCoordinate2DMake(41.89373984, -87.63532979);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.00001, 0.00001);
    MKCoordinateRegion region = MKCoordinateRegionMake(PIZZACOORDINATE, span);
    

    MKLocalSearchRequest *request = [MKLocalSearchRequest new];
    request.naturalLanguageQuery = @"pizza";
    request.region = region;
    
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error)
     {
         for (id object in response.mapItems){
             [arrayWithPlacemarks addObject:[object placemark]];
             
         }
 //        NSLog(@"%@", arrayWithPlacemarks);
     }
     ];
    
    
    for (id object in arrayWithPlacemarks){
        int x = [currentLocation distanceFromLocation:object];
        
    }
 NSArray *sortedArray = [arrayWithPlacemarks sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
     CLPlacemark *object1 = (CLPlacemark *)obj1;
     CLPlacemark *object2 = (CLPlacemark *)obj2;
     if (object1.location > object2.location){
         return (NSComparisonResult) NSOrderedDescending;
     }
     if (object1.location < object2.location){
         return (NSComparisonResult) NSOrderedAscending;
     }
     return (NSComparisonResult)NSOrderedSame;
         }];
    
    NSLog(@"%@", sortedArray);
}



-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    for (CLLocation *location in locations)
    {
            if (location.verticalAccuracy > 100 || location.horizontalAccuracy > 100)
            {
                continue;
            }
        currentLocation = location;
//                NSLog (@"%@", location);
    
            [locationManager stopUpdatingLocation];
            
    
    
            
            
        }

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}





@end
