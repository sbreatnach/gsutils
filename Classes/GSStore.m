/*
 Copyright (c) 2011-2012 GlicSoft
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 * Neither the name of GlicSoft nor the
 names of its contributors may be used to endorse or promote products
 derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL GLICSOFT BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
//
//  GSStore.m
//  gsutils
//
//  Created by Shane Breatnach on 05/04/2011.
//

#import "GSStore.h"
#import "GSStoreTransaction.h"
#import "GSStoreProduct.h"
#import "GSConstants.h"

@implementation GSStore

@synthesize invalidProductIds = _invalidProductIds;
@synthesize productIds = _productIds;
@synthesize products = _products;

- (void)dealloc
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    [_productRequest release];
    [_products release];
    [_productIds release];
    [_invalidProductIds release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if( self != nil )
    {
        _products = [[NSMutableArray alloc] init];
    }
    return self;
}


///////////////////////////////
// Public Interface
///////////////////////////////

- (BOOL)supported
{
    return [SKPaymentQueue canMakePayments];
}

- (void)requestProductData
{
    _productRequest = [[SKProductsRequest alloc]
                       initWithProductIdentifiers:_productIds];
    // link up delegates and callbacks
    _productRequest.delegate = self;
    [_productRequest start];
}

- (void)restoreCompletedTransactions
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)purchaseProductId:(NSString *)productId
{
    SKPayment *payment = [SKPayment paymentWithProductIdentifier:productId];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (GSStoreTransaction*)transactionWithProductId:(NSString *)productId
{
    GSStoreTransaction *transaction = nil;
    // search the current queue of transactions
    for( SKPaymentTransaction *queueTransaction in
        [[SKPaymentQueue defaultQueue] transactions] )
    {
        if( [queueTransaction.payment.productIdentifier isEqual:productId] )
        {
            transaction = [[[GSStoreTransaction alloc]
                            initWithTransaction:queueTransaction]
                           autorelease];
            break;
        }
    }
    return transaction;
}


///////////////////////////
// Callbacks
///////////////////////////

- (void)finishTransaction:(GSStoreTransaction*)transaction
{
    [transaction finish];
}

- (void)productDataRetrieved:(NSDictionary *)userInfo
{
    // must be implemented by subclass
}

- (void)transactionsRestored:(NSDictionary *)userInfo
{
    // optional callback
}


////////////////////////////
// SKProductsRequestDelegate
////////////////////////////

- (void)productsRequest:(SKProductsRequest *)request
     didReceiveResponse:(SKProductsResponse *)response
{
    @synchronized( _products )
    {
        [_products removeAllObjects];
        for( SKProduct *product in response.products )
        {
            GSStoreProduct *mapProduct = [[GSStoreProduct alloc]
                                          initWithProduct:product];
            [_products addObject:mapProduct];
            [mapProduct release];
        }
        self.invalidProductIds = response.invalidProductIdentifiers;
    }
    [_productRequest release];
    NSDictionary *userInfo = [NSDictionary
                              dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithBool:YES], GS_DK_Success,
                              nil];
    [self productDataRetrieved:userInfo];
    // When an observer is added, any unfinished transactions are automatically
    // resumed. To prevent possible missing initialisation, only do so AFTER
    // product data has been read and parsed.
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSDictionary *userInfo = [NSDictionary
                              dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithBool:NO], GS_DK_Success,
                              error, GS_DK_Error, nil];
    [_productRequest release];
    [self productDataRetrieved:userInfo];
}


//////////////////////////////////
// SKPaymentTransactionObserver
//////////////////////////////////

- (void)paymentQueue:(SKPaymentQueue *)queue
 updatedTransactions:(NSArray *)transactions
{
    _lastRestoreCount = 0;
    for (SKPaymentTransaction *transaction in transactions)
    {
        GSStoreTransaction *newTransaction = nil;
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStateRestored:
                _lastRestoreCount ++;
            case SKPaymentTransactionStatePurchased:
            case SKPaymentTransactionStateFailed:
                newTransaction = [[GSStoreTransaction alloc]
                                  initWithTransaction:transaction];
                break;
            default:
                break;
        }
        if( newTransaction != nil )
        {
            [self finishTransaction:newTransaction];
            [newTransaction release];
        }
    }
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    [self transactionsRestored:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [NSNumber numberWithBool:YES], GS_DK_Success,
      [NSNumber numberWithInteger:_lastRestoreCount], GS_DK_StoreRestoreCount, nil]];
}

- (void)paymentQueue:(SKPaymentQueue *)queue
restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    [self transactionsRestored:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [NSNumber numberWithBool:NO], GS_DK_Success,
      error, GS_DK_Error, nil]];
}

@end
