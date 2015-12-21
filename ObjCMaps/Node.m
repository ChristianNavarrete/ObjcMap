//
//  Node.m
//  ObjCMaps
//
//  Created by HoodsDream on 11/23/15.
//  Copyright © 2015 HoodsDream. All rights reserved.
//

#import "Node.h"

@implementation Node

-(void)addNode:(Node *)node {
  if (self.next == nil) {
    self.next = node;
  } else {
    [self.next addNode:node];
  }
}

@end
