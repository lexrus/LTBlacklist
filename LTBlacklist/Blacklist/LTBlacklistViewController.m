//
//  LTBlacklistViewController.m
//  LTBlacklist
//
//  Created by Lex on 7/12/13.
//  Copyright (c) 2013 LexTang.com. All rights reserved.
//

#import "LTBlacklistViewController.h"
#import "LTBlacklistTableViewCell.h"
#import "LTBlacklist.h"
#import "WCAlertView.h"

static const float kSegmentedControlMargin = 10.0f;

@interface LTBlacklistViewController ()<UITableViewDataSource, UITableViewDelegate, MCSwipeTableViewCellDelegate>
@property (strong, nonatomic) UITableView *tableView;

@end

@implementation LTBlacklistViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"Blacklist", nil);
        self.view.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Add", nil)
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(showAddForm)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    UIBarButtonItem *aboutButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"About", nil)
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(showAboutView)];
    self.navigationItem.leftBarButtonItem = aboutButton;
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.backgroundColor = [UIColor blackColor];
    _tableView.rowHeight = kBlacklistCellHeight;
    _tableView.separatorColor = [UIColor colorWithWhite:0.15f alpha:1.0f];
    [self.view addSubview:_tableView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - TableView datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [LTBlacklist shared].blockedItems.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LTBlacklistTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kBlacklistCellIdentifier];
    if (!cell) {
        cell = [[LTBlacklistTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kBlacklistCellIdentifier];
    }
    cell.item = [LTBlacklist shared].blockedItems[indexPath.row];
    cell.delegate = self;
    return cell;
}

#pragma mark - TableView delegate

- (void)swipeTableViewCell:(LTBlacklistTableViewCell *)cell didEndSwipingSwipingWithState:(MCSwipeTableViewCellState)state mode:(MCSwipeTableViewCellMode)mode
{
    if (state == MCSwipeTableViewCellState1) {
        [[LTBlacklist shared] blockPhoneNumber:cell.item.phoneNumber];
    } else if (state == MCSwipeTableViewCellState3) {
        [[LTBlacklist shared] unblockPhoneNumber:cell.item.phoneNumber];
    } else if (state == MCSwipeTableViewCellState2) {
        [[LTBlacklist shared] removeItem:cell.item.phoneNumber];
    } else if (state == MCSwipeTableViewCellState4) {
        
    }
    [self.tableView reloadData];
}

#pragma mark - Actions

- (void)showAddForm
{
    __weak __typeof(&*self)weakSelf = self;
    [WCAlertView showAlertWithTitle:NSLocalizedString(@"Block phone number", nil)
                            message:nil
                 customizationBlock:^(WCAlertView *alertView) {
                     alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                     UITextField *textField = [alertView textFieldAtIndex:0];
                     textField.keyboardType = UIKeyboardTypePhonePad;
                     textField.textAlignment = UITextAlignmentCenter;
                     textField.font = [UIFont boldSystemFontOfSize:18];
                 } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
                     if (buttonIndex != alertView.cancelButtonIndex) {
                         UITextField *textField = [alertView textFieldAtIndex:0];
                         NSString *phoneNumber = textField.text;
                         if (phoneNumber && phoneNumber.length > 0) {
                             [[LTBlacklist shared] blockPhoneNumber:(LTPhoneNumber*)phoneNumber];
                         }
                         __strong __typeof(&*weakSelf)strongSelf = weakSelf;
                         [strongSelf.tableView reloadData];
                     }
                 } cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                  otherButtonTitles:NSLocalizedString(@"Okay", nil), nil];
}

- (void)showAboutView
{
    [WCAlertView showAlertWithTitle:[NSString stringWithFormat:@"LTBlacklist %@", APP_VERSION]
                            message:@"By Lex Tang (http://LexTang.com)\nhttps://github.com/lexrus/LTBlacklist"
                 customizationBlock:^(WCAlertView *alertView) {
                     alertView.messageFont = [UIFont systemFontOfSize:14];
                 } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
                        
                    } cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                  otherButtonTitles:nil];
}

@end
