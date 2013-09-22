//
//  LTBlacklistTableViewCell.h
//  LTBlacklist
//
//  Created by Lex on 7/12/13.
//  Copyright (c) 2013 LexTang.com. All rights reserved.
//

#import "MCSwipeTableViewCell.h"
@class LTBlacklistItem;
@class RHPerson;

FOUNDATION_EXPORT float const kBlacklistCellHeight;
FOUNDATION_EXPORT NSString * const kBlacklistCellIdentifier;

@interface LTBlacklistTableViewCell : MCSwipeTableViewCell
@property (strong, nonatomic) LTBlacklistItem *item;
@property (assign, nonatomic, getter = isBlocked) BOOL blocked;

@end
