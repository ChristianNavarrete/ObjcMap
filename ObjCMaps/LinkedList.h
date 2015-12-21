//
//  LinkedList.h
//  ObjCMaps
//
//  Created by HoodsDream on 11/23/15.
//  Copyright © 2015 HoodsDream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Node.h"

@interface LinkedList : NSObject

@property (strong,nonatomic) Node *head;
@property (strong,nonatomic) Node *tail;
-(void)insertValue:(NSInteger)value;

@end
