#import <Foundation/Foundation.h>
#import <ZFPlayer/ZFPlayerMediaPlayback.h>

NS_ASSUME_NONNULL_BEGIN

/// 视频属性，视频资源等管理
@interface MPlayerAttributeManager : NSObject<ZFPlayerMediaPlayback>

@property (nonatomic) BOOL shouldAutoPlay;

@end

// Why is 'ZFPlayer/ZFPlayerMediaPlayback.h' file not found, and how can I fix this?

NS_ASSUME_NONNULL_END
