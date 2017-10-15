//
//  DashboardController.m
//  Fintech
//
//  Created by Markus Bröker on 12.10.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import "DashboardController.h"
#import "TickerData.h"

#import <Calculator/Calculator.h>

#define DEFAULT_BROWSER @"com.google.Chrome"

@implementation DashboardController {

    // Accounting
    NSArray *fiatCurrencies;
    NSMutableDictionary *balance;

    NSDictionary *ticker;

    Calculator *calculator;
}

@synthesize dataRows;
@synthesize exchangeTableView;
@synthesize fintechLabel;

/**
 * Refresh the Table Data
 */
- (void)refreshTable {
    dispatch_queue_t queue = dispatch_queue_create("de.4customers.fintech.refreshQueue", nil);
    dispatch_async(queue, ^{
        ticker = [calculator tickerDictionary];

        int i = 0;
        dataRows = [[NSMutableArray alloc] init];

        for (id key in ticker) {
            dataRows[i++] = [[TickerData alloc] initWithData:
                @[
                    key,
                    ticker[key][DEFAULT_LAST],
                    ticker[key][DEFAULT_LOW24],
                    ticker[key][DEFAULT_HIGH24],
                    ticker[key][DEFAULT_PERCENT],
                    ticker[key][DEFAULT_BASE_VOLUME],
                    ticker[key][DEFAULT_QUOTE_VOLUME]
                ]
            ];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            dataRows = [[dataRows sortedArrayUsingDescriptors:exchangeTableView.sortDescriptors] mutableCopy];
            [self.exchangeTableView reloadData];
        });
    });
}

/**
 * Main Entry Point for this View
 */
- (void)viewDidLoad {
    [super viewDidLoad];

    exchangeTableView.dataSource = self;
    exchangeTableView.delegate = self;

    fiatCurrencies = @[EUR, USD];

    calculator = [Calculator instance:fiatCurrencies];
    NSString *currentExchange = ([[calculator defaultExchange] isEqualToString:EXCHANGE_BITTREX]) ? @"Bittrex" : @"Poloniex";
    fintechLabel.stringValue = [NSString stringWithFormat:@"Fintech on %@", currentExchange];

    for (NSTableColumn *column in exchangeTableView.tableColumns) {
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:column.identifier.lowercaseString ascending:YES selector:@selector(compare:)];
        [column setSortDescriptorPrototype:sortDescriptor];
    }

    [self refreshTable];
}

/**
 *
 * @param sender id
 */
- (IBAction)doubleClick:(id)sender {
    NSInteger row = self.exchangeTableView.selectedRow;

    if (row == -1) { return; }

    TickerData *data = self.dataRows[row];

    if (data == nil) { return; }

    // Get the default Exchange
    NSString *defaultExchange = [calculator defaultExchange];

    NSString *url = nil;
    if ([defaultExchange isEqualToString:EXCHANGE_BITTREX]) {
        url = [NSString stringWithFormat:@"https://bittrex.com/Market/Index?MarketName=%@", [data.pair stringByReplacingOccurrencesOfString:@"_" withString:@"-"]];
    } else {
        url = [NSString stringWithFormat:@"https://poloniex.com/exchange#%@", data.pair];
    }

    [self openURL:url];
}

/**
 * Try to Open a webpage in DEFAULT_BROWSER and use the system browser as a fallback
 *
 * @param url NSString*
 */
- (void)openURL:(NSString *)url {
    NSURL *theURL = [NSURL URLWithString:url];

    @try {
        [[NSWorkspace sharedWorkspace] openURLs:@[theURL]
            withAppBundleIdentifier:DEFAULT_BROWSER
            options:NSWorkspaceLaunchDefault additionalEventParamDescriptor:nil
            launchIdentifiers:nil
        ];
    } @catch (NSException *e) {
        [[NSWorkspace sharedWorkspace] openURL:theURL];
    }
}

/**
 *
 * @param tableView
 * @return
 */
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return dataRows.count;
}

/**
 *
 * @param tableView
 * @param tableColumn
 * @param row
 * @return
 */
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {

    if (row == -1) { return nil; }
    if (row >= dataRows.count) { return nil; }

    TickerData *data = (TickerData *) dataRows[row];

    if (data == nil) { return nil; }

    if ([tableColumn.title isEqualToString:@"PAIR"]) {
        return data.pair;
    }

    if ([tableColumn.title isEqualToString:@"LAST"]) {
        return [NSString stringWithFormat:@"%.8f", [data.last doubleValue]];
    }

    if ([tableColumn.title isEqualToString:@"LOW"]) {
        return [NSString stringWithFormat:@"%.8f", [data.low doubleValue]];
    }

    if ([tableColumn.title isEqualToString:@"HIGH"]) {
        return [NSString stringWithFormat:@"%.8f", [data.high doubleValue]];
    }

    if ([tableColumn.title isEqualToString:@"CHANGE"]) {
        return [NSString stringWithFormat:@"%.2f", 100.0 * [data.change doubleValue]];
    }

    if ([tableColumn.title isEqualToString:@"baseVolume"]) {
        if (data.basevolume.doubleValue == 0) { return @"   ---   "; }
        return [NSString stringWithFormat:@"%.2f", [data.basevolume doubleValue]];
    }

    if ([tableColumn.title isEqualToString:@"quoteVolume"]) {
        if (data.quotevolume.doubleValue == 0) { return @"   ---   "; }
        return [NSString stringWithFormat:@"%.2f", [data.quotevolume doubleValue]];
    }

    if ([tableColumn.title isEqualToString:@"investmentRate"]) {
        if (data.investmentrate.doubleValue == 0) { return @"   ---   "; }
        return [NSString stringWithFormat:@"%.2f", 100.0 * [data.investmentrate doubleValue]];
    }

    return nil;
}

/**
 * Makes the table sortable
 *
 * @param aTableView NSTableView*
 * @param oldDescriptors NSArray*
 */
- (void)tableView:(NSTableView *)aTableView sortDescriptorsDidChange:(NSArray *)oldDescriptors {
    dataRows = [[dataRows sortedArrayUsingDescriptors:aTableView.sortDescriptors] mutableCopy];

    [exchangeTableView reloadData];
}

/**
 * Refresh the list
 *
 * @param sender id
 */
- (IBAction)refreshButtonAction:(id)sender {
    [self refreshTable];
}

/**
 * Refresh from another Exchange
 *
 * @param sender id
 */
- (IBAction)exchangeButtonAction:(id)sender {
    NSString *defaultExchange = [calculator defaultExchange];

    if ([defaultExchange isEqualToString:EXCHANGE_BITTREX]) {
        fintechLabel.stringValue = @"Fintech on Poloniex";
        [calculator exchange:EXCHANGE_POLONIEX withUpdate:YES];
    } else {
        fintechLabel.stringValue = @"Fintech on Bittrex";
        [calculator exchange:EXCHANGE_BITTREX withUpdate:YES];
    }

    [dataRows removeAllObjects];
    [exchangeTableView reloadData];

    [self refreshTable];
}

@end
