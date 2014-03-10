//
//  ViewController.m
//  ZaHunter
//
//  Created by Sonam Mehta on 1/22/14.
//  Copyright (c) 2014 Sonam Mehta. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
@import AddressBookUI;

@interface ViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource>
{
    
    CLLocationManager *locationManager;
    NSMutableArray *arrayWithPlacemarks;
    
    IBOutlet UITableView *tableView;
    NSMutableArray *distances;
    double numberShowingTheTotalTime;
    
    
}
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;



@end

@implementation ViewController
@synthesize segmentedControl, sortedArray, currentLocation;



- (IBAction)changingSegmentedControlValue:(UISegmentedControl *)sender {
    if(segmentedControl.selectedSegmentIndex == 0) {
        [self calculateDistancesBetweenPointsByWalking];
        [tableView reloadData];
        
    } else  if(segmentedControl.selectedSegmentIndex == 1) {
        
        [self calculateDistancesBetweenPointsByDriving];
        [tableView reloadData];
}

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    numberShowingTheTotalTime = 0.0;
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
         
       sortedArray = [arrayWithPlacemarks sortedArrayUsingComparator:^NSComparisonResult(MKPlacemark *object1, MKPlacemark *object2) {
             return [object1.location distanceFromLocation:currentLocation] - [object2.location distanceFromLocation:currentLocation];
           
 //          NSLog(@"%@", sortedArray);
         }];
         if(segmentedControl.selectedSegmentIndex == 0) {
             [self calculateDistancesBetweenPointsByWalking];
             [tableView reloadData];
         } else if (segmentedControl.selectedSegmentIndex == 0){
             [self calculateDistancesBetweenPointsByDriving];
             [tableView reloadData];
         }
         
     }];
}

- (void) calculateDistancesBetweenPointsByDriving {
    
    numberShowingTheTotalTime = 0.0;
    
    distances = nil;
    
    distances = [[NSMutableArray alloc]init];
    
    MKMapItem *currentPlace = [MKMapItem mapItemForCurrentLocation];
    
    NSMutableArray *pizzaLocations = [[NSMutableArray alloc]initWithObjects:currentPlace, sortedArray[0], sortedArray[1], sortedArray [2], sortedArray [3], nil];
    for (int i = 0; i < pizzaLocations.count - 1; i ++){
                int j = i+1;
        
        MKDirectionsRequest *request = [MKDirectionsRequest new];
        MKPlacemark *firstObject = pizzaLocations[i];
        MKMapItem *source = [[MKMapItem alloc] initWithPlacemark:firstObject];
        MKPlacemark *secondObject = pizzaLocations[j];
        MKMapItem *destination = [[MKMapItem alloc] initWithPlacemark: secondObject];
        
        request.source = source;
        request.destination = destination;
        request.transportType = MKDirectionsTransportTypeAutomobile;
        MKDirections *directions = [[MKDirections alloc]initWithRequest:request];
        [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
            MKRoute *mine = response.routes.firstObject;
            NSNumber *number = [NSNumber numberWithDouble:mine.distance];
            [distances addObject:number];
            numberShowingTheTotalTime += mine.distance;
            [tableView reloadData];
            NSLog(@"%@", distances);
            
        }];
        
    }
    
    
}


- (void) calculateDistancesBetweenPointsByWalking {
    
    numberShowingTheTotalTime = 0.0;
    distances = [[NSMutableArray alloc]init];
    
    NSMutableArray *pizzaLocations = [[NSMutableArray alloc]initWithObjects:currentLocation, sortedArray[0], sortedArray[1], sortedArray [2], sortedArray [3], nil];
    for (int i = 0; i < pizzaLocations.count - 1; i ++){
        MKMapItem *source;
        int j = i+1;
        if (i ==  0){

            source = [MKMapItem mapItemForCurrentLocation];
        } else {
            MKPlacemark *firstObject = pizzaLocations[i];
             source = [[MKMapItem alloc] initWithPlacemark:firstObject];

        }
        
         MKDirectionsRequest *request = [MKDirectionsRequest new];
         MKPlacemark *secondObject = pizzaLocations[j];
        
        
        MKMapItem *destination = [[MKMapItem alloc] initWithPlacemark: secondObject];
        request.source = source;
        request.destination = destination;
        request.transportType = MKDirectionsTransportTypeWalking;
        MKDirections *directions = [[MKDirections alloc]initWithRequest:request];
        [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
            MKRoute *mine = response.routes.firstObject;
            NSNumber *number = [NSNumber numberWithDouble:mine.distance];
            numberShowingTheTotalTime += mine.distance;
            [distances addObject:number];
            [tableView reloadData];
            NSLog(@"%@", distances);
            
        }];
        
    }

        
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

-(UITableViewCell *)tableView:(UITableView *)myTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CLPlacemark *place = sortedArray[indexPath.row];
    double value = [currentLocation distanceFromLocation:place.location];

    
    UITableViewCell *cell = [myTableView dequeueReusableCellWithIdentifier:@"Pizza Places"];
    cell.textLabel.text = place.name;
    cell.detailTextLabel.text =[NSString stringWithFormat:@"%f", value];
 
    return cell;
    
}

- (UIView *)tableView:(UITableView *)myTableView viewForFooterInSection:(NSInteger)section {
    
    
    
    UILabel* footerView = [[UILabel alloc] initWithFrame:CGRectMake(400, 400, 50, 50)];
    
    myTableView.tableFooterView = footerView;
  /*
   
    int number = 0;
    for (int i = 0; i < distances.count; i++){
        NSNumber *value = distances[i];
        number += [value intValue];
        
    }
   */
// using the value = it takes about 80 minutes to walk 100 metres
    if (numberShowingTheTotalTime != 0 && distances.count == 4){
        
        if (segmentedControl.selectedSegmentIndex == 0){
        numberShowingTheTotalTime = (numberShowingTheTotalTime/80) + 200;
        } else {
            numberShowingTheTotalTime = (numberShowingTheTotalTime/240) + 200;
        }
        
        int number = (int)numberShowingTheTotalTime;
   
    footerView.text = [NSString stringWithFormat:@"Time Taken = %i minutes", number];
    
    }
    return footerView;
}





@end
