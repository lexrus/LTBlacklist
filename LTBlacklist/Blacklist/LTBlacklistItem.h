//
//  LTBlacklistItem.h
//  LTBlacklist
//
//  Created by Lex on 7/12/13.
//  Copyright (c) 2013 LexTang.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectiveCGenerics.h"
#import "LTPhoneNumber.h"

GENERICSABLE(LTBlacklistItem)

@interface LTBlacklistItem : NSObject <NSCoding, LTBlacklistItem>

@property (strong, nonatomic) NSString *title;
@property (assign, nonatomic) BOOL blocked;
@property (assign, nonatomic) uint blockedCount;
@property (strong, nonatomic) NSString *locationName;
@property (strong, nonatomic) LTPhoneNumber *phoneNumber;
// TODO: Last block date

+ (LTBlacklistItem*)itemWithNumber:(LTPhoneNumber*)number;
+ (LTBlacklistItem*)itemWithNumber:(LTPhoneNumber*)number title:(NSString *)title;
- (id)initWithDictionary:(NSDictionary*)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
