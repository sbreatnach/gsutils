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
//  GSStore.h
//  gsutils
//
//  Created by Shane Breatnach on 05/04/2011.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@class GSStoreTransaction;

/**
 Defines a generic in-application store which contains products and the ability
 to purchase said products.
 
 For any purchase, there are two steps: retrieving the product data and
 purchasing a particular product.
 
 Every product is uniquely identified by a product ID. These product IDs must
 be supplied by the client code, either hard-coded or retrieved from a server.
 All products are defined via a GSStoreProduct class instance.
 */
@interface GSStore : NSObject
<SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
    SKProductsRequest *_productRequest;
    NSSet *_productIds;
    NSArray *_invalidProductIds;
    NSMutableArray *_products;
    NSUInteger _lastRestoreCount;
}

/**
 The set of product identifier strings for the store. Must be set before any
 requests for product data is made.
 */
@property (nonatomic, retain) NSSet *productIds;
/**
 The list of invalid product identifier strings for the store. Updated 
 after each request for product data.
 */
@property (nonatomic, retain) NSArray *invalidProductIds;
/**
 The list of products that have been read from the store.
 */
@property (retain, readonly) NSArray *products;

/**
 Returns true if the store is supported in the current application;
 NO otherwise.
 */
- (BOOL)supported;
/**
 Start the asynchronous request to get the product data from the external
 store service, using the current set of product IDs.
 
 When complete, -productDataRetrieved: is invoked.
 */
- (void)requestProductData;
/**
 Starts an async request to the external store service to restore any completed
 transactions by the current user. Note that this must be done after the 
 products are read from the store service, via -requestProductData
 
 When complete, -productDataRetrieved: is invoked if any transactions are 
 restored. -transactionsRestored: is invoked either way with success or failure
 information.
 */
- (void)restoreCompletedTransactions;
/**
 Callback function when requestProductData completes. Must be implemented
 by subclass.
 userInfo contains NSNumber bool flag with the key constant GS_DK_SUCCESS and
 the resulting NSError with key constant GS_DK_ERROR if the request failed.
 */
- (void)productDataRetrieved: (NSDictionary*)userInfo;
/**
 Callback function when restoreCompletedTransactions completes. 
 userInfo contains NSNumber bool flag with the key constant GS_DK_SUCCESS and
 the resulting NSError with key constant GS_DK_ERROR if the request failed.
 */
- (void)transactionsRestored: (NSDictionary*)userInfo;
/**
 Initiates the asynchronous request to purchase the given product ID. When
 complete, -finishTransaction: is invoked.
 */
- (void)purchaseProductId: (NSString*)productId;
/**
 Returns the first transaction found that is for the given product ID. If no
 such transaction exists, nil is returned.
 */
- (GSStoreTransaction*)transactionWithProductId: (NSString*)productId;
/**
 Finishes the given transaction, whether it succeeded or failed. 
 Callback function when purchaseProductId completes. Must be implemented
 by subclass. 
 */
- (void)finishTransaction: (GSStoreTransaction*)transaction;

@end
