//
//  YLPBusiness.h
//  ios-code-challenge
//
//  Created by Dustin Lange on 1/21/18.
//  Copyright © 2018 Dustin Lange. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface YLPBusiness : NSObject

- (instancetype)initWithAttributes:(NSDictionary *)attributes;

/**
 *  Yelp id of this business.
 */
@property (nonatomic, readonly, copy) NSString *identifier;

/**
 *  Name of this business.
 */
@property (nonatomic, readonly, copy) NSString *name;

/**
 *  Categories for this business.
 */
@property (nonatomic, readonly, copy) NSArray *categories;

/**
 *  Rating for this business.
 */
@property double rating;

/**
 *  Review count for this business.
 */
@property int reviewCount;

/**
 *  Distance from this business.
 */
@property double distance;

/**
 *  URL for thumbnail image for this business.
 */
@property (nonatomic, readonly, copy) NSString *thumbnailURLText;

@end

NS_ASSUME_NONNULL_END
