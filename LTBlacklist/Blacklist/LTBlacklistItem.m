//
//  LTBlacklistItem.m
//  LTBlacklist
//
//  Created by Lex on 7/12/13.
//  Copyright (c) 2013 LexTang.com. All rights reserved.
//

#import "LTBlacklistItem.h"

@implementation LTBlacklistItem

+ (LTBlacklistItem*)itemWithNumber:(LTPhoneNumber*)number
{
    if (!number) return nil;
    return [LTBlacklistItem itemWithNumber:number title:@""];
}

+ (LTBlacklistItem*)itemWithNumber:(LTPhoneNumber*)number title:(NSString *)title
{
    NSDictionary *dict = @{@"phoneNumber": number,
                           @"title": title,
                           @"blocked": @(NO),
                           @"blockedCount": @(0)};
    LTBlacklistItem *instance = [[LTBlacklistItem alloc] initWithDictionary:dict];
    return instance;
}

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.phoneNumber = dict[@"phoneNumber"];
        self.title = dict[@"title"];
        self.blocked = [dict[@"blocked"] boolValue];
        self.blockedCount = [dict[@"blockedCount"] unsignedIntValue];
    }
    return self;
}

- (NSDictionary *)dictionaryRepresentation
{
    NSDictionary *dict = @{@"title": self.title,
                           @"phoneNumber": self.phoneNumber,
                           @"blocked": @(self.blocked),
                           @"blockedCount": @(self.blockedCount)};
    return dict;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ %@", self.title, self.phoneNumber];
}

#pragma mark - NSCoding methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    self.phoneNumber = [aDecoder decodeObjectForKey:@"phoneNumber"];
    self.title = [aDecoder decodeObjectForKey:@"title"];
    self.blocked = [aDecoder decodeBoolForKey:@"blocked"];
    self.blockedCount = [aDecoder decodeInt64ForKey:@"blockedCount"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.phoneNumber forKey:@"phoneNumber"];
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeBool:self.blocked forKey:@"blocked"];
    [aCoder encodeInt64:self.blockedCount forKey:@"blockedCount"];
}

@end
