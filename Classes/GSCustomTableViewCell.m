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
//  GSCustomTableViewCell.m
//  gsutils
//
//  Created by Shane Breatnach on 11/04/2011.
//

#import "GSCustomTableViewCell.h"

static NSString *GSCustomCellIdentifier = @"GSCustomCell";

@implementation GSCustomTableViewCell

@synthesize cell = _cell;

- (void)dealloc
{
    [_cell release];
    [super dealloc];
}

- (id)initWithNibName: (NSString*)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [self initWithStyle:UITableViewCellStyleDefault
               reuseIdentifier:[[self class] customReuseIdentifier]];
    if( self != nil )
    {
        [[NSBundle mainBundle] loadNibNamed:nibNameOrNil
                                      owner:self
                                    options:nil];
        [self.contentView addSubview:self.cell.contentView];
        self.accessoryView = self.cell.accessoryView;
        self.backgroundView = self.cell.backgroundView;
        self.editingAccessoryView = self.cell.editingAccessoryView;
        self.selectedBackgroundView = self.cell.selectedBackgroundView;
        self.accessoryType = self.cell.accessoryType;
    }
    return self;
}

+ (id)cell
{
    return nil;
}

+ (NSString*)customReuseIdentifier
{
    return GSCustomCellIdentifier;
}

@end
