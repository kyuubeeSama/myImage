//
//  NSDate+Category.h
//  quanyihui
//
//  Created by liuqingyuan on 2019/3/25.
//  Copyright © 2019 qyhl. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (Category)
// 根据时间戳获取date时间
+(NSDate *)getDateWithTimeStamp:(NSString *)timeStamp;

+(NSString *)createTimeWithTimeStamp:(NSString *)timeStamp  dateFormat:(NSString * _Nullable)dateFormat;

/**两个Date之间的比较*/
- (NSDateComponents *)intervalToDate:(NSDate *)date;
/**与当前时间比较*/
- (NSDateComponents *)intervalToNow;

- (int)intervalSinceNow:(NSString *) theDate;

//当前时间的时间戳
+ (NSString *)nowTimestamp;

+(NSDictionary *)getTimeOfDate:(NSDate *)date;

// 输出距离指定时间的时分秒
+(NSString *)getDayHourWithTimeStamp:(NSString *)timeStamp;

@end

NS_ASSUME_NONNULL_END
