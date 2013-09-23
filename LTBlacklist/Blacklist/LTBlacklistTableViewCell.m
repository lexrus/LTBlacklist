//
//  LTBlacklistTableViewCell.m
//  LTBlacklist
//
//  Created by Lex on 7/12/13.
//  Copyright (c) 2013 LexTang.com. All rights reserved.
//

#import "LTBlacklistTableViewCell.h"
#import "LTBlacklist.h"

float const kBlacklistCellHeight = 44;
NSString * const kBlacklistCellIdentifier = @"kBlacklistCellIdentifier";

@implementation LTBlacklistTableViewCell
{
    UILabel *_blockedIndicator;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.textLabel.textColor = [UIColor whiteColor];
        
        [self setFirstStateIconName:@"BlockIcon"
                         firstColor:[UIColor colorWithWhite:0.2 alpha:1.0f]
                secondStateIconName:@""
                        secondColor:[UIColor redColor]
                      thirdIconName:@"UnblockIcon"
                         thirdColor:[UIColor colorWithWhite:0.2 alpha:1.0f]
                     fourthIconName:@""
                        fourthColor:[UIColor greenColor]];
        [self.contentView setBackgroundColor:[UIColor whiteColor]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self setMode:MCSwipeTableViewCellModeSwitch];
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (newSuperview) {
        self.contentView.backgroundColor = [UIColor blackColor];
    }
}

- (void)setItem:(LTBlacklistItem *)item
{
    _item = item;
    self.textLabel.font = [UIFont systemFontOfSize:16];
    if (_item.blockedCount <= 1) {
        self.textLabel.text = _item.phoneNumber;
    } else {
        self.textLabel.text = [NSString stringWithFormat:@"%@ x %i", _item.phoneNumber, _item.blockedCount];
    }
    self.blocked = _item.blocked;
}

- (void)setBlocked:(BOOL)blocked
{
    if (blocked) {
        if (!_blockedIndicator) {
            _blockedIndicator = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, kBlacklistCellHeight)];
            _blockedIndicator.backgroundColor = [UIColor clearColor];
            _blockedIndicator.textColor = [UIColor whiteColor];
            _blockedIndicator.font = [UIFont systemFontOfSize:12];
            _blockedIndicator.textAlignment = (UITextAlignment)UITextAlignmentRight;
            _blockedIndicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
            _blockedIndicator.frame = CGRectMake(self.bounds.size.width - 100 - 15,
                                                 0,
                                                 100,
                                                 kBlacklistCellHeight);
            _blockedIndicator.text = NSLocalizedString(@"BLOCKED", nil);
            [self.contentView addSubview:_blockedIndicator];
        }
    } else if (_blockedIndicator) {
        [_blockedIndicator removeFromSuperview];
        _blockedIndicator = nil;
    }
}

@end
