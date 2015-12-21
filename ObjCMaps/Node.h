//
//  Node.h
//  ObjCMaps
//
//  Created by HoodsDream on 11/23/15.
//  Copyright © 2015 HoodsDream. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Node : NSObject

@property (strong, nonatomic) Node *next;
@property (nonatomic) NSInteger data;

-(void)addNode:(Node*)node;

@end
