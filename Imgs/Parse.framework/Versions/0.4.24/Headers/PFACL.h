//  PFACL.h
//  Copyright 2011 Parse, Inc. All rights reserved.

#import <Foundation/Foundation.h>

@class PFUser;

/*!
 The PFACL is an access control list that can apply to a PFObject. The PFACL determines which users have
 read and write permissions to the object.
 */
@interface PFACL : NSObject <NSCopying> {
    NSMutableDictionary *permissionsById;    
}

/*!
 Creates an ACL with no permissions granted.
 */
+ (PFACL *)ACL;

/*!
 Creates an ACL where only the provided user has access.
 */
+ (PFACL *)ACLWithUser:(PFUser *)user;

/*!
 Set whether the public is allowed to read this object.
 */
- (void)setPublicReadAccess:(BOOL)allowed;

/*!
 Set whether the public is allowed to write this object.
 */
- (void)setPublicWriteAccess:(BOOL)allowed;

/*!
 Set whether the given user id is allowed to read this object.
 */
- (void)setReadAccess:(BOOL)allowed forUserId:(NSString *)userId;

/*!
 Set whether the given user id is allowed to write this object.
 */
- (void)setWriteAccess:(BOOL)allowed forUserId:(NSString *)userId;

/*!
 Set whether the given user is allowed to read this object.
 */
- (void)setReadAccess:(BOOL)allowed forUser:(PFUser *)user;

/*!
 Set whether the given user is allowed to write this object.
 */
- (void)setWriteAccess:(BOOL)allowed forUser:(PFUser *)user;

@end
