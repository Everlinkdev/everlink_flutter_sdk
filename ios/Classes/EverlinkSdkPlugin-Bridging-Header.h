#import <EverlinkBroadcastSDK/EverlinkBroadcastSDK.h>

@protocol EverlinkEventDelegate <NSObject>
- (void)onAudiocodeReceivedWithToken:(NSString * _Nonnull)token;
- (void)onMyTokenGeneratedWithToken:(NSString * _Nonnull)token oldToken:(NSString * _Nonnull)oldToken;
@end
