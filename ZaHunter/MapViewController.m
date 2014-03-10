//
//  MapViewController.m
//  ZaHunter
//
//  Created by Siddharth Sukumar on 1/23/14.
//  Copyright (c) 2014 Sonam Mehta. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import "ViewController.h"


@interface MapViewController () <MKMapViewDelegate>
{
    
    IBOutlet MKMapView *myMapView;
}
@property (nonatomic) ViewController *tableViewClass;

@end

@implementation MapViewController

@synthesize tableViewClass;
/*
- (ViewController *) tableViewClass {
    if (!tableViewClass)
        tableViewClass = [[tableViewClass alloc]init];
}
 */

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self showDirectionsTo:tableViewClass.sortedArray];
}

- (void) showDirectionsTo: (NSArray *)array{
    
    MKMapItem *currentPlace = [MKMapItem mapItemForCurrentLocation];
    
 
    NSMutableArray *pizzaLocations = [[NSMutableArray alloc]initWithObjects:currentPlace, array[0], array[1], array[2], array[3], nil];
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
            MKPolyline *polyline = [response.routes.firstObject polyline];
            [myMapView addOverlay:polyline level:MKOverlayLevelAboveRoads];

            
        }];
        
    }

    
    
}



- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    
    MKPolylineRenderer *routeRenderer = [[MKPolylineRenderer alloc]initWithPolyline:overlay];
    routeRenderer.strokeColor = [UIColor redColor];
    return routeRenderer;
    
    
}

@end
