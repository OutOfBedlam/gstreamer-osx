//
//  gstreamer_osxTests.m
//  gstreamer-osxTests
//
//  Created by Eirny on 1/15/16.
//  Copyright © 2016 Yet Reader Forge. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface gstreamerTests : XCTestCase

@end

@implementation gstreamerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
//    NSString *pluginPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"/usr/lib/gstreamer-1.0"];
//    NSLog(@"pluginPath = %@", pluginPath);
//
//    GstRegistry *registry = gst_registry_get();
}

#if 0
- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}
#endif
@end
