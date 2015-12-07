//
//  PirateConverter.h
//  PirateText
//
//  Created by Markus Feng on 9/30/15.
//  Copyright © 2015 Markus Feng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PirateConverter : NSObject{
    int mutableStringOffset;
}

@property NSDictionary * dictionary;
@property NSDictionary * multiWordDictionary;

-(NSString *)convertFromEnglishToPirate: (NSString *) value;

@end
