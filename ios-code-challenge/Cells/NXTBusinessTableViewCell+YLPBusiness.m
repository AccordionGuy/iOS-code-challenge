//
//  NXTBusinessTableViewCell+YLPBusiness.m
//  ios-code-challenge
//
//  Created by Dustin Lange on 1/21/18.
//  Copyright © 2018 Dustin Lange. All rights reserved.
//

#import "NXTBusinessTableViewCell+YLPBusiness.h"
#import "YLPBusiness.h"
#import <math.h>

@implementation NXTBusinessTableViewCell (YLPBusiness) 

- (void)configureCell:(YLPBusiness *)business
{
    NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:business.thumbnailURLText]];
    self.thumbnailImage.image = [UIImage imageWithData:imageData];
    
    self.nameLabel.text = business.name;
    //self.ratingLabel.text = business.ra //[self ratingToStars:business.rating];
    self.distanceLabel.text = [NSString stringWithFormat:@"%.1f miles", [self metersToMiles:business.distance]];
    self.reviewCountLabel.text = [NSString stringWithFormat:@"%d reviews", business.reviewCount];
    
    NSLog(@"business.categories = %@",business.categories[0][@"title"]);
    self.categoriesLabel.text = [self categoryTitles:business.categories];
}


#pragma mark - Data conversion functions

- (NSString *)ratingToStars:(double)rating
{
    double wholeNumberPart;
    double fractionPart = modf(rating, &wholeNumberPart);
    int wholeNumberRating = (int)wholeNumberPart;
    bool hasHalfStar = (fractionPart == 0.5);
    

    NSString *stars = [@"" stringByPaddingToLength:wholeNumberRating withString:@"★" startingAtIndex:0];
    NSMutableString *starBuilder = [[NSMutableString alloc] initWithString:stars];
    if (hasHalfStar) {
        [starBuilder appendString:@"½"];
    }
    return [NSString stringWithString:starBuilder];
}

- (double)metersToMiles:(double)meters
{
    static double const METERS_PER_MILE = 1609.344;
    return meters / METERS_PER_MILE;
}

- (NSString *)categoryTitles:(NSArray *)categories {
    NSMutableString *categoryTitlesBuilder = [[NSMutableString alloc] init];
    NSUInteger numCategories = [categories count];
    for (int i = 0; i < numCategories; i++) {
        [categoryTitlesBuilder appendString:categories[i][@"title"]];
        if (i != (numCategories - 1)) {
            [categoryTitlesBuilder appendString:@", "];
        }
    }
    return [NSString stringWithString:categoryTitlesBuilder];
}


#pragma mark - NXTBindingDataForObjectDelegate

- (void)bindingDataForObject:(id)object
{
    [self configureCell:(YLPBusiness *)object];
}

@end
