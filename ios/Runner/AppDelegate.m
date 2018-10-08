#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import <Photos/Photos.h>

@implementation AppDelegate



- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
    FlutterViewController *controller = (FlutterViewController*)self.window.rootViewController;
    FlutterMethodChannel *saveToPhotosAlbum = [FlutterMethodChannel methodChannelWithName:@"samples.flutter.io/battery" binaryMessenger:controller];
    [saveToPhotosAlbum setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
        if ([@"saveToPhotosAlbum" isEqualToString:call.method]) {
            NSDictionary *arguments = [call arguments];
            NSString *filePath = arguments[@"file"];
//            NSArray *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
//            NSString *documentsPath = [docPath objectAtIndex:0];
            
//            UIImage *fileimg = [[UIImage init] initWithFileAtPath:shareText];
//            [self loadImageFinished:fileimg];
            
            NSString *resultstr = @"Y";
//            if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
            PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
            if (status == PHAuthorizationStatusRestricted ||
                status == PHAuthorizationStatusDenied) {
                resultstr = @"N";
            }
//            }
            if ([resultstr isEqualToString:@"Y"]) {
                UIImage *fileimg = [UIImage imageWithContentsOfFile:filePath];
                [self loadImageFinished:fileimg];
            }
            result(resultstr);
            return;
        }
        result(FlutterMethodNotImplemented);
    }];
    
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)loadImageFinished:(UIImage *)image
{
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"保存到系统相册失败" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
        [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
        [self performSelector:@selector(dismiss:) withObject:alert afterDelay:2.0];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"已保存到系统相册" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
        [self performSelector:@selector(dismiss:) withObject:alert afterDelay:1.0];
    }
//    NSString *info = [NSString stringWithFormat:@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo];
//    UIActivityViewController *activityViewController =
//    [[UIActivityViewController alloc] initWithActivityItems:@[ image ]
//                                      applicationActivities:nil];
//    [self.window.rootViewController presentViewController:activityViewController animated:YES completion:nil];
}

- (void)dismiss:(UIAlertController *)alert{
    [alert dismissViewControllerAnimated:YES completion:nil];
}

@end
