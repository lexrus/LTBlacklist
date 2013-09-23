//
//  LTBlacklist.m
//  LTBlacklist
//
//  Created by Lex on 7/22/13.
//  Copyright (c) 2013 LexTang.com. All rights reserved.
//

#import "LTBlacklist.h"
#import <CoreTelephony/CTCall.h>

#define kBlockedPhoneNumbersCacheKey @"blockedPhoneNumbers"

typedef NS_ENUM(short, CTCallStatus) {
    kCTCallStatusCallIn = 4,
    kCTCallStatusHungUp = 5
};

static const CFStringRef kCTCallStatusChangeNotification = CFSTR("kCTCallStatusChangeNotification");
extern NSString *CTCallCopyAddress(void*, CTCall *);
extern void CTCallDisconnect(CTCall*);
extern CFNotificationCenterRef CTTelephonyCenterGetDefault();
extern void CTTelephonyCenterAddObserver(CFNotificationCenterRef center,
                                         const void *observer,
                                         CFNotificationCallback callBack,
                                         CFStringRef name,
                                         const void *object,
                                         CFNotificationSuspensionBehavior suspensionBehavior);
extern void CTTelephonyCenterRemoveObserver(CFNotificationCenterRef center,
                                            const void *observer,
                                            CFStringRef name,
                                            const void *object);

@interface LTBlacklist ()

@property (strong, nonatomic) NSCache *cache;
@property (copy, nonatomic, readonly) NSString *path;

@end

@implementation LTBlacklist

+ (instancetype)shared
{
    static dispatch_once_t onceToken;
    static LTBlacklist *__instance;
    dispatch_once(&onceToken, ^{
        __instance = [[super alloc] init];
        __instance.cache = [[NSCache alloc] init];
    });
    return __instance;
}


#pragma mark - Private

- (NSString *)path
{
    static dispatch_once_t pathToken;
    static NSString *__path;
    dispatch_once(&pathToken, ^{
        __path = (NSString*)NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                NSUserDomainMask,
                                                                YES)[0];
    });
    return __path;
}

- (NSString *)blacklistPath
{
    return [self.path stringByAppendingPathComponent:@"LTBlacklist.json"];
}

#pragma mark - Phone observer control

static void callHandler(CFNotificationCenterRef center, void *observer,
                        CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    NSDictionary *info = (__bridge NSDictionary *)(userInfo);
    CTCall *call = (CTCall *)info[@"kCTCall"];
    CTCallStatus status = (CTCallStatus)[info[@"kCTCallStatus"] shortValue];
    
    if (status == kCTCallStatusCallIn) {
        LTPhoneNumber *phoneNumber = (LTPhoneNumber *)CTCallCopyAddress(NULL, call);
        
        NSLog(@"Call in: %@", phoneNumber);
        
        LTBlacklistItem *item = [[LTBlacklist shared] itemByPhoneNumber:phoneNumber];
        if (item) {
            if (item.blocked) {
                item.blockedCount++;
                CTCallDisconnect(call);
            }
            
            [[LTBlacklist shared] updateBlockedItem:item];
            [[LTBlacklist shared] notify:phoneNumber];
        } else {
            [[LTBlacklist shared] addItem:phoneNumber];
        }
    }
}

- (void)notify:(LTPhoneNumber*)phoneNumber
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.fireDate = [[NSDate date] dateByAddingTimeInterval:1.5f];
    notification.alertBody = [NSString stringWithFormat:@"Blocked %@", phoneNumber];
    notification.alertAction = NSLocalizedString(@"Show LTBlacklist", nil);
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

- (void)activate {
    CTTelephonyCenterAddObserver(CTTelephonyCenterGetDefault(),
                                 NULL,
                                 &callHandler,
                                 kCTCallStatusChangeNotification,
                                 NULL,
                                 CFNotificationSuspensionBehaviorHold
                                 );
}

- (void)deactivate {
    CTTelephonyCenterRemoveObserver(CTTelephonyCenterGetDefault(),
                                    NULL,
                                    kCTCallStatusChangeNotification,
                                    NULL);
}

#pragma mark - Blacklist read & write

- (NSArray<LTBlacklistItem>*)blockedItems
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self blacklistPath]]) {
        NSData *jsonData = [NSData dataWithContentsOfFile:[self blacklistPath]];
        NSArray<LTBlacklistItem> *blockedItems = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:NULL];
        NSMutableArray *parsedItems = [NSMutableArray array];
        if (blockedItems && [blockedItems isKindOfClass:[NSArray class]]) {
            for (NSDictionary *itemDict in blockedItems) {
                [parsedItems addObject:[[LTBlacklistItem alloc] initWithDictionary:itemDict]];
            }
            return parsedItems;
        }
    }
    return @[];
}

- (void)setBlockedItems:(NSArray *)blockedItems
{
    NSError *serializeError = nil;
    
    NSMutableArray *serialzableItems = [NSMutableArray array];
    for (LTBlacklistItem *item in blockedItems) {
        [serialzableItems addObject:[item dictionaryRepresentation]];
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:serialzableItems options:0 error:&serializeError];
    if (serializeError.code != noErr) {
        NSLog(@"%@", serializeError.localizedDescription);
        return;
    }
    
    NSError *writeError = nil;
    [jsonData writeToFile:[self blacklistPath] options:NSDataWritingAtomic error:&writeError];
    if (writeError.code != noErr) {
        NSLog(@"%@", writeError.localizedDescription);
    }
}

#pragma mark - Blacklist manager

- (NSArray<LTPhoneNumber> *)blockedPhoneNumbers {
    NSArray *__blockedPhoneNumbers = [self.cache objectForKey:kBlockedPhoneNumbersCacheKey];
    if (!__blockedPhoneNumbers) {
        NSMutableArray *newBlockedPhoneNumbers = [NSMutableArray array];
        for (LTBlacklistItem *item in self.blockedItems) {
            if (item.blocked)
                [newBlockedPhoneNumbers addObject:item.phoneNumber.description];
        }
        __blockedPhoneNumbers = [NSArray arrayWithArray:newBlockedPhoneNumbers];
        [self.cache setObject:__blockedPhoneNumbers forKey:kBlockedPhoneNumbersCacheKey];
    }
    return __blockedPhoneNumbers;
}

- (LTBlacklistItem*)itemByPhoneNumber:(LTPhoneNumber*)phoneNumber
{
    if (!phoneNumber) return nil;
    for (LTBlacklistItem *item in self.blockedItems) {
        if ([phoneNumber rangeOfString:item.phoneNumber].location != NSNotFound) {
            return item;
        }
    }
    return nil;
}

- (void)updateBlockedItem:(LTBlacklistItem*)blockedItem
{
    NSMutableArray *newItems = [NSMutableArray arrayWithArray:self.blockedItems];
    uint i = 0;
    for (LTBlacklistItem *item in newItems) {
        if ([item.phoneNumber isEqualToString:blockedItem.phoneNumber]) {
            [newItems replaceObjectAtIndex:i withObject:blockedItem];
            break;
        }
        i++;
    }
    self.blockedItems = newItems;
}

- (void)unblockPhoneNumber:(LTPhoneNumber *)phoneNumber {
    NSMutableArray *newItems = [NSMutableArray arrayWithArray:self.blockedItems];
    for (LTBlacklistItem *item in newItems) {
        if ([item.phoneNumber.description isEqualToString:phoneNumber]) {
            item.blocked = NO;
            break;
        }
    }
    self.blockedItems = newItems;
}

- (void)blockPhoneNumber:(LTPhoneNumber *)phoneNumber {
    NSMutableArray *newItems = [NSMutableArray arrayWithArray:self.blockedItems];
    BOOL exists = NO;
    for (LTBlacklistItem *item in newItems) {
        if ([item.phoneNumber isEqualToString:phoneNumber]) {
            item.blocked = YES;
            exists = YES;
            break;
        }
    }
    if (!exists) {
        LTBlacklistItem *item = [LTBlacklistItem itemWithNumber:phoneNumber];
        if (item) {
            item.blocked = YES;
            [newItems addObject:item];
        }
    }
    self.blockedItems = newItems;
}

- (void)addItem:(LTPhoneNumber *)phoneNumber
{
    NSMutableArray *newItems = [NSMutableArray arrayWithArray:self.blockedItems];
    BOOL exists = NO;
    for (LTBlacklistItem *item in newItems) {
        if ([item.phoneNumber isEqualToString:phoneNumber]) {
            exists = YES;
            break;
        }
    }
    if (!exists) {
        LTBlacklistItem *newItem = [LTBlacklistItem itemWithNumber:phoneNumber];
        [newItems addObject:newItem];
    }
    self.blockedItems = newItems;
}

- (void)removeItem:(LTPhoneNumber *)phoneNumber
{
    NSMutableArray *newItems = [NSMutableArray arrayWithArray:self.blockedItems];
    for (LTBlacklistItem *item in newItems) {
        if ([item.phoneNumber isEqualToString:phoneNumber]) {
            [newItems removeObject:item];
            break;
        }
    }
    self.blockedItems = newItems;
}

@end
