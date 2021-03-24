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
//  GSStoreTransaction.h
//  gsutils
//
//  Created by Shane Breatnach on 05/04/2011.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>


/**
 Contains the underlying the transaction and defines some basic interfaces
 for accessing and handling the transaction.
 */
@interface GSStoreTransaction : NSObject
{
    SKPaymentTransaction *_transaction;
    NSString *_receipt;
}

@property (nonatomic, retain, readonly) NSError *error;
@property (nonatomic, assign, readonly) BOOL successful;
@property (nonatomic, assign, readonly) BOOL failed;
@property (nonatomic, assign, readonly) BOOL restored;
@property (nonatomic, retain, readonly) NSString *productId;
/**
 The Base64-encoded string of the transaction receipt.
 */
@property (nonatomic, assign, readonly) NSString *receipt;

- (id)initWithTransaction: (SKPaymentTransaction*)transaction;
/**
 Runs back-end clean up code. MUST be called once the transaction is considered
 complete.
 */
- (void)finish;

@end
