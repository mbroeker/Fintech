//
//  TickerData.m
//  Fintech
//
//  Created by Markus Bröker on 12.10.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import "TickerData.h"

/**
 * Sortable TickerData for the DataSource
 */
@implementation TickerData

- (id)initWithData:(NSArray *)data {

    if (self = [super init]) {

        self.pair = data[0];
        self.last = data[1];
        self.low = data[2];
        self.high = data[3];
        self.change = data[4];
        self.basevolume = data[5];
        self.quotevolume = data[6];

        self.investmentrate = @([self.last doubleValue] / ([data[5] doubleValue] / [data[6] doubleValue]) - 1.0);
        if (isnan(self.investmentrate.doubleValue)) { self.investmentrate = @0; };

    }

    return self;
}

@end
