//
//  DashboardController.m
//  Fintech
//
//  Created by Markus Bröker on 12.10.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import "DashboardController.h"
#import "TickerData.h"

#import <Brokerage/Brokerage.h>
#import <Calculator/Calculator.h>

@implementation DashboardController {
    // Accounting
    NSArray *assets;
    NSArray *fiatCurrencies;
    NSMutableDictionary *balance;

    NSDictionary *ticker;

    Broker *broker;
    id exchange;
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
        ticker = [exchange ticker:assets forFiatCurrencies:fiatCurrencies];

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

    assets = [@{
        @"BTCD": @"Bitcoin Dark",
        @"BTC": @"Bitcoin",
        @"BTS": @"BitShares",
        @"DASH": @"Digital Cash",
        @"DCR": @"Decred",
        @"DGB": @"DigiBytes",
        @"DOGE": @"Dogecoin",
        @"EMC2": @"Einsteinium",
        @"ETC": @"Ethereum Classic",
        @"ETH": @"Ethereum",
        @"GAME": @"GameCredits",
        @"LSK": @"Lisk",
        @"LTC": @"Litecoin",
        @"MAID": @"SafeMaid",
        @"OMG": @"Omise GO",
        @"SC": @"Siacoin",
        @"STEEM": @"Steem",
        @"STRAT": @"Stratis",
        @"SYS": @"Syscoin",
        @"XEM": @"New Economy",
        @"XMR": @"Monero",
        @"XRP": @"Ripple",
        @"ZEC": @"ZCash",
        @"ADA": @"Cardano",
        @"ADX": @"AD Token",
        @"ARK": @"Ark Byte",
        @"BAT": @"Basic Attention",
        @"BCC": @"Bitcoin Cash",
        @"ERC": @"Europe Coin",
        @"IOP": @"Internet of People",
        @"KMD": @"Komodo",
        @"MCO": @"Monaco",
        @"NEO": @"NEO",
        @"OK": @"OK",
        @"PAY": @"Pay Token",
        @"PTC": @"Pesetacoin",
        @"QTUM": @"Qtum",
        @"RDD": @"Redd Coin",
        @"RISE": @"Rise",
        @"XLM": @"Lumen",
        @"XVG": @"The Verge",
    } allKeys];

    broker = [[Broker alloc] init];
    exchange = [broker exchange:EXCHANGE_POLONIEX];
    fintechLabel.stringValue = @"Fintech on Poloniex";

    for (NSTableColumn *column in exchangeTableView.tableColumns) {
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:column.identifier.lowercaseString ascending:YES selector:@selector(compare:)];
        [column setSortDescriptorPrototype:sortDescriptor];
    }

    [self refreshTable];
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
    if ([exchange class]  == [Bittrex class]) {
        fintechLabel.stringValue = @"Fintech on Poloniex";
        exchange = [broker exchange:EXCHANGE_POLONIEX];
    } else {
        fintechLabel.stringValue = @"Fintech on Bittrex";
        exchange = [broker exchange:EXCHANGE_BITTREX];
    }

    [dataRows removeAllObjects];
    [exchangeTableView reloadData];

    [self refreshTable];
}
@end
