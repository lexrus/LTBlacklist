//
//  LTBlacklist.h
//  LTBlacklist
//
//  Created by Lex on 7/22/13.
//  Copyright (c) 2013 LexTang.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LTPhoneNumber.h"
#import "LTBlacklistItem.h"

@interface LTBlacklist : NSObject
@property (strong, nonatomic, readonly) NSArray<LTPhoneNumber> *blockedPhoneNumbers;
@property (strong, nonatomic, readonly) NSArray<LTBlacklistItem> *blockedItems;

+ (LTBlacklist *)shared;

#pragma mark - Phone observer control

- (void)activate;
- (void)deactivate;


#pragma mark - Blacklist manager

- (void)blockPhoneNumber:(LTPhoneNumber*)phoneNumber;
- (LTBlacklistItem*)itemByPhoneNumber:(LTPhoneNumber*)phoneNumber;
- (void)updateBlockedItem:(LTBlacklistItem*)blockedItem;
- (void)unblockPhoneNumber:(LTPhoneNumber*)phoneNumber;
- (void)addItem:(LTPhoneNumber*)phoneNumber;
- (void)removeItem:(LTPhoneNumber*)phoneNumber;

@end
