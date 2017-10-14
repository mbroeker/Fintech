//
//  DashboardController.h
//  Fintech
//
//  Created by Markus Bröker on 12.10.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
 * Dashboard - Controller
 *
 * @author      Markus Bröker<broeker.markus@googlemail.com>
 * @copyright   Copyright (C) 2017 4customers UG
 */
@interface DashboardController : NSViewController <NSTableViewDelegate, NSTableViewDataSource>

@property(strong) IBOutlet NSTableView *exchangeTableView;
@property (strong) IBOutlet NSTextField *fintechLabel;


@property(strong) NSMutableArray *dataRows;

@property(strong) IBOutlet NSButton *refreshButton;
@property (strong) IBOutlet NSButton *exchangeButton;

/**
 * @param sender id
 */
- (IBAction)refreshButtonAction:(id)sender;
- (IBAction)exchangeButtonAction:(id)sender;

/**
 * Refresh the Table Data
 */
- (void)refreshTable;

@end
