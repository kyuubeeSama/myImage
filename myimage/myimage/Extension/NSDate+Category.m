//
//  NSDate+Category.m
//  quanyihui
//
//  Created by liuqingyuan on 2019/3/25.
//  Copyright © 2019 qyhl. All rights reserved.
//

#import "NSDate+Category.h"

@implementation NSDate (Category)

+(NSDate *)getDateWithTimeStamp:(NSString *)timeStamp{
    if (timeStamp.length > 10) {
        timeStamp = [NSString stringWithFormat:@"%f",[timeStamp doubleValue]/1000];
    }
    NSString *str=timeStamp;
    NSTimeInterval time = [str doubleValue];
    NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
    return detaildate;
}

+(NSString *)createTimeWithTimeStamp:(NSString *)timeStamp dateFormat:(NSString * _Nullable)dateFormat
{
    if (timeStamp.length > 10) {
        timeStamp = [NSString stringWithFormat:@"%f",[timeStamp doubleValue]/1000];
    }
    NSString *str=timeStamp;
    NSTimeInterval time = [str doubleValue];
    NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
    //2.实例化一个日期格式转换器
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    
    //3.指定地区一定要指定，否则真机运行会有问题，统一用 en 即可
    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en"];
    //4.设置输出格式
    if ([NSString MyStringIsNULL:dateFormat]){
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    }else{
        dateFormatter.dateFormat = dateFormat;
    }

    //5.通过日期格式转换器将NSDate类转换成可以输出的字符串.
    NSString *currentDateStr = [dateFormatter stringFromDate:detaildate];
//    NSLog(@"当前的时间: %@",currentDateStr);
    return currentDateStr;
//    return [detaildate description];
}

- (NSDateComponents *)intervalToDate:(NSDate *)date
{
    // 日历对象
    NSCalendar *calender = [NSCalendar currentCalendar];
    
    // 获得一个时间元素
    NSCalendarUnit  unit =  NSCalendarUnitYear | NSCalendarUnitMonth
    | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute |NSCalendarUnitSecond;
    
    return [calender components:unit fromDate:self toDate:date options:kNilOptions];
}
- (NSDateComponents *)intervalToNow
{
    return [self intervalToDate:[NSDate date]];
}

// 得到的结果为相差的天数
- (int)intervalSinceNow:(NSString *) theDate
{
    
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    // 这里的格式根据自己的需要自行确定（yyyy-MM-dd hh:mm:ss）
    [date setDateFormat:@"yyyy-MM-dd"];
    NSDate *d=[date dateFromString:theDate];
//    NSGregorianCalendar
    NSInteger unitFlags = NSCalendarUnitDay| NSCalendarUnitMonth | NSCalendarUnitYear;
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [cal components:unitFlags fromDate:d];
    NSDate *newBegin  = [cal dateFromComponents:comps];
    
    // 当前时间
    NSCalendar *cal2 = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps2 = [cal2 components:unitFlags fromDate:[NSDate date]];
    NSDate *newEnd  = [cal2 dateFromComponents:comps2];
    
    
    NSTimeInterval interval = [newEnd timeIntervalSinceDate:newBegin];
    NSInteger resultDays=((NSInteger)interval)/(3600*24);
    
    return (int) resultDays;
}

//当前时间的时间戳
+ (NSString *)nowTimestamp{
    NSDate *newDate = [NSDate date];
    long int timeSp = (long)[newDate timeIntervalSince1970];
    NSString *tempTime = [NSString stringWithFormat:@"%ld",timeSp];
    return tempTime;
}  

+(NSDictionary *)getTimeOfDate:(NSDate *)date {
    //获取当前时间
    NSDate *now = date;
//    NSLog(@"now date is: %@", now);
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    NSInteger year = [dateComponent year];
    NSInteger month = [dateComponent month];
    NSInteger day = [dateComponent day];
    NSInteger hour = [dateComponent hour];
    NSInteger minute = [dateComponent minute];
    NSInteger second = [dateComponent second];
    NSDictionary *timeDic = @{@"year":[NSString stringWithFormat:@"%ld",(long)year],@"month":[NSString stringWithFormat:@"%ld",(long)month],@"day":[NSString stringWithFormat:@"%ld",(long)day],@"hour":[NSString stringWithFormat:@"%ld",(long)hour],@"minute":[NSString stringWithFormat:@"%ld",(long)minute],@"second":[NSString stringWithFormat:@"%ld",(long)second]};
    return timeDic;
}

+(NSString *)getDayHourWithTimeStamp:(NSString *)timeStamp
{
    //得到当前时间
    NSDate *nowData = [NSDate date];
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    NSTimeZone* timeZone2 = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone2];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString *datestr=[formatter stringFromDate:nowData];
    NSDate *nowOrderedDate = [formatter dateFromString:datestr];
    
    //    NSLog(@"---当前时间：%@",nowData);
    //    NSDate *endData=[NSDate dateWithTimeIntervalSince1970:endTime];
    NSDateFormatter *myFormatter = [[NSDateFormatter alloc]init];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [myFormatter setTimeZone:timeZone];
    [myFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    //传入日期
    NSDate *endData2 = [myFormatter dateFromString:timeStamp];
    NSTimeInterval time =  endData2.timeIntervalSince1970 + 5;
    NSDate *endData = [NSDate dateWithTimeIntervalSince1970:time ];
    
    //    NSLog(@"----结束时间%@",endData);
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSUInteger unitFlags = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;
    NSDateComponents *cps = [calendar components:unitFlags fromDate:nowOrderedDate toDate: endData options:0];
    NSInteger Hour = [cps hour];
    NSInteger Min = [cps minute];
    NSInteger Sec = [cps second];
        NSInteger Day = [cps day];
    //    NSInteger Mon = [cps month];
    //    NSInteger Year = [cps year];
    //    NSLog( @" From Now to %@, diff: Years: %ld Months: %ld, Days; %ld, Hours: %ld, Mins:%ld, sec:.%ld",
    //          [nowData description], (long)Year, (long)Mon, (long)Day, (long)Hour, (long)Min,(long)Sec );
    //    NSString *countdown = [NSString stringWithFormat:@"还剩: %zi天 %zi小时 %zi分钟 %zi秒 ", Day,Hour, Min, Sec];
    NSString *countdown = [NSString stringWithFormat:@"%02ld天%02ld时%02ld分%02ld秒",(long)Day,(long)Hour, (long)Min, (long)Sec];
    //    NSLog(@"0000%@",countdown);
    if (Sec < 0 || Day<0 || Hour <0 || Min <0) {
        countdown = @"已结束";
//        countdown=[NSString stringWithFormat:@"1"];
    }
    return countdown;
}

@end
