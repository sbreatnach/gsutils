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
//  GSCustomTableViewCell.h
//  gsutils
//
//  Created by Shane Breatnach on 11/04/2011.
//

#import <UIKit/UIKit.h>


/**
 As an alternative to the Apple way of subclassing table view cells, this
 class may be subclassed to offer full IBOutlet connections in a Nib, like
 what is expected with other UIView classes.
 
 A two-step process is needed.
 1) Create a subclass that inherits from this class.
 2) Create a Nib with a table view cell as the only root object.
 Make the File Owner for the Nib the subclass and connect the cell IBOutlet
 to the root table view cell.
 All other Nib connections in the subclass will be applied and displayed as
 expected.
 
 The subclass MUST be initialised with the -initWithNibName:bundle: message with
 the created Nib name as an argument. 
 The +cell message SHOULD be overridden if an autoreleased instance of the cell
 is needed. This way, the Nib name can be specified within the class definition.
 The subclass MAY override the +customReuseIdentifier message definition
 if the reuseIdentifier system is used for the table view.
 */
@interface GSCustomTableViewCell : UITableViewCell
{
    UITableViewCell *_cell;
}

/**
 Outlet connection required in subclass Nib file.
 */
@property (nonatomic, retain) IBOutlet UITableViewCell *cell;

/**
 Convenience message to create autoreleased instance of cell. Returns nil
 by default. MUST be overridden in subclass to be usable.
 */
+ (id)cell;
/**
 Designated initialiser for this cell class.
 */
- (id)initWithNibName: (NSString*)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
/**
 Returns a standard reuse identifier for cells. MAY be overridden by subclasses
 if necessary.
 */
+ (NSString*)customReuseIdentifier;

@end
