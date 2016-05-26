//
//  OAPoiViewController.h
//  OsmAnd
//
//  Created by Alexey Kulish on 19/05/16.
//  Copyright © 2016 OsmAnd. All rights reserved.
//

#import "OATargetMenuViewController.h"

@class OAPOI;
@class OARowInfo;

@protocol OARowInfoDelegate <NSObject>

@optional
- (void)onRowClick:(OATargetMenuViewController *)sender rowInfo:(OARowInfo *)rowInfo;

@end

@interface OARowInfo : NSObject

@property (nonatomic) NSString *key;
@property (nonatomic) UIImage *icon;
@property (nonatomic) NSString *text;
@property (nonatomic) NSString *textPrefix;
@property (nonatomic) UIColor *textColor;
@property (nonatomic) BOOL isText;
@property (nonatomic) BOOL isHtml;
@property (nonatomic) BOOL needLinks;
@property (nonatomic) BOOL isPhoneNumber;
@property (nonatomic) BOOL isUrl;
@property (nonatomic) int order;
@property (nonatomic) NSString *typeName;

@property (nonatomic) int height;
@property (nonatomic) BOOL moreText;

@property (weak, nonatomic) id<OARowInfoDelegate> delegate;

- (instancetype)initWithKey:(NSString *)key icon:(UIImage *)icon textPrefix:(NSString *)textPrefix text:(NSString *)text textColor:(UIColor *)textColor isText:(BOOL)isText needLinks:(BOOL)needLinks order:(int)order typeName:(NSString *)typeName isPhoneNumber:(BOOL)isPhoneNumber isUrl:(BOOL)isUrl;

@end

@interface OAPOIViewController : OATargetMenuViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, readonly) OAPOI *poi;
@property (nonatomic) NSArray<OARowInfo *> *additionalRows;

- (id)initWithPOI:(OAPOI *)poi;

- (UIImage *) getIcon:(NSString *)fileName;

@end
