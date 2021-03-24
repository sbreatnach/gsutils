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
//  GSNSDate+Utilities.h
//  gsutils
//
//  Created by Shane Breatnach on 24/01/2012.
//  Copyright (c) 2012 GlicSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (GSUtilities)

/**
 * Returns a human-readable string of the receiver, based on the current
 * date and time. Duplicates the behaviour of the Mail app time label. 
 * If there is less than a day between the current time and the receiver,
 * a string in the format "HH:mm" is returned.
 * If there is less than two days between the current time and the receiver,
 * a string in the format "Yesterday" is returned.
 * If there is less than 7 days between the current time and the receiver,
 * a string in the format "<weekday>" is returned.
 * Otherwise, the date is formatted in ISO format using the current locale.
 * All output is localised where required.
 */
- (NSString*)humanReadableString;
/**
 * Returns a human-readable string of the receiver, based on the current
 * date and time.  Duplicates the behaviour of the Mail app time label. 
 * If there is less than a day between the current time and the receiver,
 * a string in the format "HH:mm" is returned.
 * If there is less than two days between the current time and the receiver,
 * a string in the format "Yesterday" is returned.
 * If there is less than 7 days between the current time and the receiver,
 * a string in the format "<weekday>" is returned.
 * Otherwise, the date is formatted in ISO format using the current locale.
 * All output is localised where required.
 */
- (NSString*)humanReadableStringWithLocale:(NSLocale*)locale;

@end
