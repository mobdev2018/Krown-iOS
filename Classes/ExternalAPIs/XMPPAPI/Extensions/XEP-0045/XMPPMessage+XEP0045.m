#import "XMPPMessage+XEP0045.h"
#import "NSXMLElement+XMPP.h"
#import <objc/objc-runtime.h>

@implementation XMPPMessage(XEP0045)

+(void)load
{
    Method isGroupChatMessage = class_getInstanceMethod(self, @selector(isGroupChatMessage));
    Method isGroupChatMessageCustom = class_getInstanceMethod(self, @selector(isGroupChatMessageCustom));
    Method isGroupChatMessageWithBody = class_getInstanceMethod(self, @selector(isGroupChatMessageWithBody));
    Method isGroupChatMessageWithBodyCustom = class_getInstanceMethod(self, @selector(isGroupChatMessageWithBodyCustom));
    
    method_exchangeImplementations(isGroupChatMessage, isGroupChatMessageCustom);
    method_exchangeImplementations(isGroupChatMessageWithBody, isGroupChatMessageWithBodyCustom);
}

- (BOOL)isGroupChatMessageCustom
{
	return [[[self attributeForName:@"type"] stringValue] isEqualToString:@"groupchat"];
}

- (BOOL)isGroupChatMessageWithBodyCustom
{
	if ([self isGroupChatMessage])
	{
		NSString *body = [[self elementForName:@"body"] stringValue];
		
		return ([body length] > 0);
	}
	
	return NO;
}



- (BOOL)isGroupChatMessageWithSubject
{
    if ([self isGroupChatMessage])
	{
        NSString *subject = [[self elementForName:@"subject"] stringValue];

		return ([subject length] > 0);
    }

    return NO;
}

- (NSString *)subject
{
	return [[self elementForName:@"subject"] stringValue];
}

- (void)addSubject:(NSString *)subject
{
    NSXMLElement *subjectElement = [NSXMLElement elementWithName:@"subject" stringValue:subject];
    [self addChild:subjectElement];
}

@end
