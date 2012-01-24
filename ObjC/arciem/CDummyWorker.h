//
//  CDummyWorker.h
//  QP2
//
//  Created by Robert McNally on 1/23/12.
//  Copyright (c) 2012 QP Corp. All rights reserved.
//

#import "CWorker.h"
#import "CWorkerManager.h"

@interface CDummyWorker : CWorker

+ (void)testWithWorkerManager:(CWorkerManager*)workerManager;

@end
