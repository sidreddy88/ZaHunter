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
@import AddressBookUI;

@interface ViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource>
{
    CLLocation *currentLocation;
    CLLocationManager *locationManager;
    NSMutableArray *arrayWithPlacemarks;
    NSArray *sortedArray;
    IBOutlet UITableView *tableView;
    
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
}

- (void)search {
    MKCoordinateSpan span = MKCoordinateSpanMake(.000001, .0000001);
    MKCoordinateRegion region = MKCoordinateRegionMake(currentLocation.coordinate, span);
    
    MKLocalSearchRequest *request = [MKLocalSearchRequest new];
    request.naturalLanguageQuery = @"pizza";
    request.region = region;
    
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error)
     {
         for (id object in response.mapItems)
             [arrayWithPlacemarks addObject:[object placemark]];
         
       sortedArray = [arrayWithPlacemarks sortedArrayUsingComparator:^NSComparisonResult(CLPlacemark *object1, CLPlacemark *object2) {
             return [object1.location distanceFromLocation:currentLocation] - [object2.location distanceFromLocation:currentLocation];
           NSLog(@"%@", sortedArray);
         }];

         [tableView reloadData];
     }];
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
    
        [locationManager stopUpdatingLocation];

        [self search];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CLPlacemark *place = sortedArray[indexPath.row];
    double value = [currentLocation distanceFromLocation:place.location];
    
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Pizza Places"];
    cell.textLabel.text = place.name;
    cell.detailTextLabel.text =[NSString stringWithFormat:@"%f", value];
    
    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:place.location completionHandler:^(NSArray *placemarks, NSError *error) {
        for (CLPlacemark *placemark in placemarks) {
            //             labelShowingAddress.text = placemark;
            id name =  ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO);
//            cell.detailTextLabel.text = name;
            
            
                    }
    }];

    
    return cell;
    
}





@end
