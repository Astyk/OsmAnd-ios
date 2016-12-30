//
//  OASelectSubcategoryViewController.h
//  OsmAnd
//
//  Created by Alexey Kulish on 29/12/2016.
//  Copyright © 2016 OsmAnd. All rights reserved.
//

#import "OASuperViewController.h"

@class OAPOICategory;

@protocol OASelectSubcategoryDelegate

@required

- (void)selectSubcategoryCancel;
- (void)selectSubcategoryDone:(OAPOICategory *)category keys:(NSMutableSet<NSString *> *)keys allSelected:(BOOL)allSelected;

@end

@interface OASelectSubcategoryViewController : OASuperViewController

@property (nonatomic, weak) id<OASelectSubcategoryDelegate> delegate;

- (instancetype)initWithCategory:(OAPOICategory *)category subcategories:(NSSet<NSString *> *)subcategories selectAll:(BOOL)selectAll;

@end
