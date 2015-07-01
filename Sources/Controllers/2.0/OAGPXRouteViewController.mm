//
//  OAGPXRouteViewController.m
//  OsmAnd
//
//  Created by Alexey Kulish on 01/07/15.
//  Copyright (c) 2015 OsmAnd. All rights reserved.
//

#import "OAGPXRouteViewController.h"
#import "OAGPXDetailsTableViewCell.h"
#import "OAGPXElevationTableViewCell.h"
#import "OsmAndApp.h"
#import "OAGPXDatabase.h"
#import "OAGPXDocumentPrimitives.h"
#import "OAGPXDocument.h"
#import "OAGPXMutableDocument.h"
#import "PXAlertView.h"
#import "OAEditGroupViewController.h"
#import "OAEditColorViewController.h"
#import "OADefaultFavorite.h"

#import "OAMapRendererView.h"
#import "OARootViewController.h"
#import "OANativeUtilities.h"
#import "Localization.h"
#import "OAUtilities.h"
#import "OASavingTrackHelper.h"
#import "OAGpxWptItem.h"

#import "OAGPXRouteWptListViewController.h"

#include <OsmAndCore.h>
#include <OsmAndCore/Utilities.h>

@interface OAGPXRouteViewController ()

@property (nonatomic) OAGPXDocument *doc;

@end

@implementation OAGPXRouteViewController
{
    OAGPXRouteWptListViewController *_waypointsController;
    
    OsmAndAppInstance _app;
    NSDateFormatter *_dateTimeFormatter;
    
    OAMapViewController *_mapViewController;
    
    OAGpxRouteSegmentType _segmentType;
    CGFloat _scrollPos;
    BOOL _wasInit;

    UIView *_badge;
}

- (id)initWithGPXItem:(OAGPX *)gpxItem
{
    self = [super init];
    if (self)
    {
        _app = [OsmAndApp instance];
        _wasInit = NO;
        _scrollPos = 0.0;
        _segmentType = kSegmentRoute;
        self.gpx = gpxItem;
        [self loadDoc];
    }
    return self;
}

- (void)loadDoc
{
    NSString *path = [_app.gpxPath stringByAppendingPathComponent:self.gpx.gpxFileName];
    self.doc = [[OAGPXDocument alloc] initWithGpxFile:path];
}

- (void)cancelPressed
{
    [_mapViewController hideTempGpxTrack];
    
    if (self.delegate)
        [self.delegate btnCancelPressed];
    
    [self closePointsController];
}

- (void)okPressed
{
    if (self.delegate)
        [self.delegate btnOkPressed];
    
    [self closePointsController];
}

- (BOOL)preHide
{
    [_mapViewController keepTempGpxTrackVisible];
    [_mapViewController hideTempGpxTrack];
    [self closePointsController];
    return YES;
}

- (BOOL)supportFullMenu
{
    return _segmentType == kSegmentRouteWaypoints;
}

- (BOOL)supportFullScreen
{
    return _segmentType == kSegmentRouteWaypoints;
}

- (BOOL)fullScreenWithoutHeader
{
    return YES;
}

-(BOOL)hasTopToolbar
{
    return YES;
}

- (BOOL)shouldShowToolbar:(BOOL)isViewVisible;
{
    return YES;
}

- (id)getTargetObj
{
    return self.gpx;
}

- (CGFloat)contentHeight
{
    /*
    if (_waypointsController)
    {
        CGFloat h = 0.0;
        for (NSInteger i = 0; i < [_waypointsController.tableView numberOfSections]; i++)
        {
            h += 44.0;
            h += [_waypointsController.tableView numberOfRowsInSection:i] * 44.0;
        }
        return MIN(160.0, h);
    }
     */
    return 160.0;
}

- (void)applyLocalization
{
    [self.buttonCancel setTitle:OALocalizedString(@"shared_string_back") forState:UIControlStateNormal];
    [self.buttonCancel setImage:[UIImage imageNamed:@"menu_icon_back"] forState:UIControlStateNormal];
    [self.buttonCancel setTintColor:[UIColor whiteColor]];
    self.buttonCancel.titleEdgeInsets = UIEdgeInsetsMake(0.0, 12.0, 0.0, 0.0);
    self.buttonCancel.imageEdgeInsets = UIEdgeInsetsMake(0.0, -12.0, 0.0, 0.0);
    
    [self.segmentView setTitle:OALocalizedString(@"gpx_route") forSegmentAtIndex:0];
    [self.segmentView setTitle:OALocalizedString(@"gpx_waypoints") forSegmentAtIndex:1];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _mapViewController = [OARootViewController instance].mapPanel.mapViewController;
    
    _dateTimeFormatter = [[NSDateFormatter alloc] init];
    _dateTimeFormatter.dateStyle = NSDateFormatterShortStyle;
    _dateTimeFormatter.timeStyle = NSDateFormatterMediumStyle;
    
    self.titleView.text = [self.gpx getNiceTitle];
    
    _waypointsController = [[OAGPXRouteWptListViewController alloc] initWithLocationMarks:self.doc.locationMarks];
    _waypointsController.allGroups = [self readGroups];
    
    _waypointsController.view.frame = self.view.frame;
    [_waypointsController doViewAppear];
    [self.contentView addSubview:_waypointsController.view];

    [self.segmentView setSelectedSegmentIndex:_segmentType];
    [self applySegmentType];

    [self addBadge];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_mapViewController showTempGpxTrack:self.gpx.gpxFileName];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addBadge
{
    if (_badge)
    {
        [_badge removeFromSuperview];
        _badge = nil;
    }
    
    UILabel *badgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 50.0)];
    badgeLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:11.0];
    badgeLabel.text = [NSString stringWithFormat:@"%d", self.doc.locationMarks.count];
    badgeLabel.textColor = UIColorFromRGB(0xFF8F00);
    badgeLabel.textAlignment = NSTextAlignmentCenter;
    [badgeLabel sizeToFit];
    
    CGSize badgeSize = CGSizeMake(MAX(16.0, badgeLabel.bounds.size.width + 8.0), MAX(16.0, badgeLabel.bounds.size.height));
    badgeLabel.frame = CGRectMake(.5, .5, badgeSize.width, badgeSize.height);
    CGRect badgeFrame = CGRectMake(self.segmentView.bounds.size.width - badgeSize.width + 10.0, -4.0, badgeSize.width, badgeSize.height);
    _badge = [[UIView alloc] initWithFrame:badgeFrame];
    _badge.layer.cornerRadius = 8.0;
    _badge.layer.backgroundColor = [UIColor whiteColor].CGColor;
    
    [_badge addSubview:badgeLabel];
    
    [self.segmentViewContainer addSubview:_badge];
}

- (void)closePointsController
{
    if (_waypointsController)
    {
        [_waypointsController resetData];
        [_waypointsController doViewDisappear];
        _waypointsController = nil;
    }
}

- (void)applySegmentType
{
    switch (_segmentType)
    {
        case kSegmentRoute:
        {
            if (self.delegate)
                [self.delegate requestHeaderOnlyMode];
            
            break;
        }
        case kSegmentRouteWaypoints:
        {
            if (!_wasInit && _scrollPos != 0.0)
                [_waypointsController.tableView setContentOffset:CGPointMake(0.0, _scrollPos)];
            
            _waypointsController.view.frame = self.contentView.bounds;
            
            if (self.delegate)
                [self.delegate requestFullScreenMode];
            
            break;
        }
            
        default:
            break;
    }
    
    _wasInit = YES;
}

- (NSArray *)readGroups
{
    NSMutableSet *groups = [NSMutableSet set];
    for (OAGpxWpt *wptItem in self.doc.locationMarks)
    {
        if (wptItem.type.length > 0)
            [groups addObject:wptItem.type];
    }
    return [groups allObjects];
}

- (void)updateMap
{
    [[OARootViewController instance].mapPanel displayGpxOnMap:self.gpx];
}

- (IBAction)segmentClicked:(id)sender
{
    OAGpxRouteSegmentType newSegmentType = (OAGpxRouteSegmentType)self.segmentView.selectedSegmentIndex;
    if (_segmentType == newSegmentType)
        return;
    
    _segmentType = newSegmentType;
    
    [self applySegmentType];
}

@end