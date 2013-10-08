//
//  WeiboUser+Builder.m
//  SinaWeibo
//
//  Created by cxjwin on 13-8-29.
//  Copyright (c) 2013年 cxjwin. All rights reserved.
//

#import "WeiboUser+Builder.h"

@implementation WeiboUser (Builder)

- (void)fillInDetailsWithJSONObject:(NSDictionary *)info {
  if (info) {
    self.userId = [info objectForKey:@"id"];
    self.screenName = [info objectForKey:@"screen_name"];
    self.name = [info objectForKey:@"name"];
    self.province = [info objectForKey:@"province"];
    self.city = [info objectForKey:@"city"];
    self.location = [info objectForKey:@"location"];
    self.description = [info objectForKey:@"description"];
    self.url = [info objectForKey:@"url"];
    self.profileUrl = [info objectForKey:@"profile_url"];
    self.profileImageUrl = [info objectForKey:@"profile_image_url"];
    self.domain = [info objectForKey:@"domain"];
    self.weihao = [info objectForKey:@"weihao"];
    self.gender = [info objectForKey:@"gender"];
    self.followersCount = [info objectForKey:@"followers_count"];
    self.friendsCount = [info objectForKey:@"friends_count"];
    self.statusesCount = [info objectForKey:@"statuses_count"];
    self.favouritesCount = [info objectForKey:@"favourites_count"];
    self.createdAt = [info objectForKey:@"created_at"];
    self.following = [info objectForKey:@"following"];
    self.allowAllActMsg = [info objectForKey:@"allow_all_act_msg"];
    self.remark = [info objectForKey:@"remark"];
    self.geoEnabled = [info objectForKey:@"geo_enabled"];
    self.verified = [info objectForKey:@"verified"];
    self.status = [info objectForKey:@"status"];
    self.allowAllComment = [info objectForKey:@"allow_all_comment"];
    self.avatarLarge = [info objectForKey:@"avatar_large"];
    self.verifiedReason = [info objectForKey:@"verified_reason"];
    self.followMe = [info objectForKey:@"follow_me"];
    self.onlineStatus = [info objectForKey:@"online_status"];
    self.biFollowersCount = [info objectForKey:@"bi_followers_count"];
    self.lang = [info objectForKey:@"lang"];
  }
}

@end
