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
        self.last = @([data[1] doubleValue]);
        self.low = @([data[2] doubleValue]);
        self.high = @([data[3] doubleValue]);
        self.change = @([data[4] doubleValue]);
        self.base = @([data[5] doubleValue]);
        self.quote = @([data[6] doubleValue]);

        double ivr = [self.last doubleValue] / ([data[5] doubleValue] / [data[6] doubleValue]) - 1.0;
        self.ir = @(ivr);

        self.er = @([data[7] doubleValue]);
        self.balance = @([data[8] doubleValue]);

        if (isnan(self.ir.doubleValue)) { self.ir = @0; };
        if (isinf(self.ir.doubleValue)) { self.ir = @0; };

        if (isnan(self.er.doubleValue)) { self.er = @0; };
        if (isinf(self.er.doubleValue)) { self.er = @0; };

    }

    return self;
}

@end
