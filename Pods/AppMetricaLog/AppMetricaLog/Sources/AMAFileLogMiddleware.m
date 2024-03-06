
#import "AMAFileLogMiddleware.h"

@interface AMAFileLogMiddleware ()

@property (nonatomic, strong) NSFileHandle *fileHandle;

@end

@implementation AMAFileLogMiddleware

- (instancetype)initWithFileHandle:(NSFileHandle *)fileHandle
{
    self = [super init];
    if (self) {
        _fileHandle = fileHandle;
    }
    return self;
}

- (BOOL)isAsyncLoggingAcceptable
{
    return YES;
}

- (void)logMessage:(NSString *)message level:(AMALogLevel)level
{
    if (message == nil) {
        return;
    }

    NSString *formattedMessage = [NSString stringWithFormat:@"%@%@", message, @"\n"];
    NSData *messageData = [formattedMessage dataUsingEncoding:NSUTF8StringEncoding];
    [self.fileHandle writeData:messageData];
}

@end
