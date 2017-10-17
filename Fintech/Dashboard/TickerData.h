//
//  TickerData.h
//  Fintech
//
//  Created by Markus Bröker on 12.10.17.
//  Copyright © 2017 Markus Bröker. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * TickerData for DataSource
 *
 * @author      Markus Bröker<broeker.markus@googlemail.com>
 * @copyright   Copyright (C) 2017 4customers UG
 */
@interface TickerData : NSObject

@property(strong) NSString *pair;
@property(strong) NSNumber *last;
@property(strong) NSNumber *high;
@property(strong) NSNumber *low;
@property(strong) NSNumber *change;
@property(strong) NSNumber *base;
@property(strong) NSNumber *quote;
@property(strong) NSNumber *ir;
@property(strong) NSNumber *er;
@property(strong) NSNumber *balance;

- (id)initWithData:(NSArray *)data;

@end
