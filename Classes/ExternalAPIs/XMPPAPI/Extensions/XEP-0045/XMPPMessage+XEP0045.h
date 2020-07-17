#import <Foundation/Foundation.h>
#import "XMPPMessage.h"


@interface XMPPMessage(XEP0045)

+(void)load;
- (BOOL)isGroupChatMessageCustom;
- (BOOL)isGroupChatMessageWithBodyCustom;
- (BOOL)isGroupChatMessageWithSubject;


- (NSString *)subject;
- (void)addSubject:(NSString *)subject;

@end
