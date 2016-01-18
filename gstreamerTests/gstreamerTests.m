//
//  gstreamer_osxTests.m
//  gstreamer-osxTests
//
//  Created by Eirny on 1/15/16.
//  Copyright © 2016 Yet Reader Forge. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <gst/gst.h>

@interface gstreamerTests : XCTestCase

@end

@implementation gstreamerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

static gint plugin_sort_name(gconstpointer a, gconstpointer b)
{
    return strcasecmp(gst_plugin_get_name(GST_PLUGIN(a)), gst_plugin_get_name(GST_PLUGIN(b)));
}

static void on_plugin_added (GstRegistry *registry, GstPlugin *plugin, gpointer user_data)
{
    NSLog(@"%s: %s", __func__, gst_plugin_get_name(plugin));
}

- (void)testPluginRegistry
{
    gst_init(NULL, NULL);

    GstRegistry *registry = gst_registry_get();

    if (!g_signal_connect(registry, "plugin-added", G_CALLBACK(on_plugin_added), (__bridge gpointer)self))
    {
        NSLog(@"%s Error PluginRegistry plugin-added signal connection failure", __func__);
    }

    GList *list = gst_registry_get_plugin_list(registry);
    list = g_list_sort(list, plugin_sort_name);
    while(list) {
        GstPlugin *plugin = GST_PLUGIN(list->data);
        NSLog(@"Plugin: %s (%s)", gst_plugin_get_name(plugin), gst_plugin_get_filename(plugin));
        list = g_list_next(list);
    }
    gst_plugin_list_free(list);

    gst_deinit();
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
