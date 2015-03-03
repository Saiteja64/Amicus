//
//  MXClient.h
//  MoxtraSDK
//
// Created by KenYu on 6/16/14.
// Copyright (c) 2013 Moxtra, Inc. All rights reserved.
//
// Check detail information in Moxtra SDK API documents.
//

// The domain for error responses from API calls
extern NSString *const MXClientErrorDomain;

// The MXClient may also return other NSError objects from other domains, such as
// * NSURLError domain

//Error code
typedef NS_ENUM(NSInteger, MXClientErrorCode) {
    
    MXClientErrorUnknownStatusCode = -3000,
    
    MXClientErrorNetworkError = 101,
    
    //Init account
    MXClientErrorUserAccountAlreadyExist = 104,
    MXClientErrorUserAccountSetupFailed = 105,
    
    //Update user's profile
    MXClientErrorUpdateUserProfileFailed = 130,
    
    //Create chat
    MXClientErrorChatStartFailed = 500,
    //Invite chat members
    MXClientErrorInviteMembersFailed = 502,
    //Invite meet attendees
    MXClientErrorInviteMeetAttendeesFailed = 503,
    //Delete chat
    MXClientErrorChatDeleteFailed = 504
};


@interface MXChatMemberInfo : NSObject
@property (nonatomic, readonly, copy)NSString* firstName;
@property (nonatomic, readonly, copy)NSString* lastName;
@property (nonatomic, readonly, copy)NSString* avatarPath;
@end

@interface MXChatSession : NSObject
@property (nonatomic, readonly, copy) NSString *binderID;
@property (nonatomic, readonly, copy) NSString *topic;
@property (nonatomic, readonly, assign) BOOL isOwner;
@property (nonatomic, readonly, copy) NSString *converImagePath;
@property (nonatomic, readonly, assign) UInt64 lastFeedTimeStamp;
@property (nonatomic, readonly, assign) NSUInteger unreadFeedCount;
@property (nonatomic, readonly, copy) NSString *lastFeedContent;
@property (nonatomic, readonly, strong) NSArray *memberInfoArray;   //MXChatMemberInfo objects, at most 4 objects in this array
@end


#pragma mark -
@protocol MXClientChatDelegate <NSObject>
@optional

/**
 * Return YES if the 3rd party need hide invite button in meet. The default values is NO.
 */
- (BOOL)hideInviteButton;

/**
 * Called when the user invite attendees via pressing invite button in meet. The default values are both YES.
 */
- (BOOL)supportInviteContactsBySMS;
- (BOOL)supportInviteContactsByEmail;

/**
 * Called when the user invite attendees via pressing invite button in meet. Return the customized subject/body.
 * There will be default subject/body if return value is null.
 */
- (NSString *)bodyOfSMSContentWithMeetLink:(NSString*)meetLink;
- (NSString *)subjectOfEmailContent;
- (NSString *)HTMLBodyOfEmailContentWithMeetLink:(NSString*)meetLink;

/**
 * Called when 3rd party want to customize invite members process if user press invite button in binder setting.
 */
- (void)presentInviteChatMembersViewController:(UIViewController*)presentingViewController binderID:(NSString*)binderID;

/**
 * Called when 3rd party want to customize invite attendees process if user press invite button in meet.
 */
- (void)presentInviteMeetAttendeesViewController:(UIViewController*)presentingViewController meetID:(NSString *)meetID;

/**
 * Called when 3rd party want to customize member's profile view controller if user try to view member's profile in chat or in the chat setting view controller.
 */
- (void)presentChatMemberProfileViewController:(UIViewController*)presentingViewController uniqueID:(NSString *)uniqueID;

/**
 * Called when 3rd party want to customize add files view controller if user try to add files via pressing "+" button.
 * If this delegate is not be implemented, the default "+" panel will be showed.
 */
- (void)presentAddFilesViewController:(UIViewController*)presentingViewController;

/**
 * Called when 3rd party want to add files if user try to add files via pressing "..." button in default "+" panel.
 * If this delegate is not be implemented, the "..." button will not be showed in default "+" panel.
 */
- (void)presentMoreFilesViewController:(UIViewController*)presentingViewController;

/**
 * Called when user press back button on chat view controller.
 * If this delegate is not be implemented, the chatViewController will be dismiss/pop automatically when user press back button.
 */
- (void)popChatViewController:(UIViewController*)chatViewController;

/**
 * Called when there are some changes for chat.
 */
- (void)onChatSessionUpdated:(MXChatSession*)chatSession;
- (void)onChatSessionCreated:(MXChatSession*)chatSession;
- (void)onChatSessionDeleted:(MXChatSession*)chatSession;

/**
 * Called when there is a update event on chat from remote notifications.
 */
- (void)onChatRemoteNotification:(NSString *)binderID;
@end


#pragma mark -
/**
 * There are two user identity types and use for different cases.
 * User case one (kUserIdentityTypeIdentityUniqueID): you do not have a Moxtra account, and you just need to provide a unique id before use Moxtra client functions.
 */
typedef enum enumUserIdentityType {
    kUserIdentityTypeIdentityUniqueID = 0,
    kUserIdentityTypeSSOAccessToken
}MXUserIdentityType;


@interface MXUserIdentity : NSObject
@property (nonatomic, assign) MXUserIdentityType userIdentityType;
@property (nonatomic, copy) NSString *userIdentity;
@end


#pragma mark -
@protocol MXClient <NSObject>

// chat delegate for notifying the calling application during the chat.
@property (nonatomic, readwrite, weak) id<MXClientChatDelegate> delegate;

#pragma mark initialize user
/**
 * Setup user information. It need OAuth login with Moxtra Account.
 * The 3rd party should not call any other APIs except clientWithApplicationClientID before initializeUserAccount success block call back.
 *
 * @param userIdentity
 *            The user identity.
 * @param orgID
 *            The user org identity.
 * @param firstName
 *            User's firstName.
 * @param lastName
 *            User's lastName.
 * @param avatar
 *            User's avatar image. If need we will resize it according to the image size.
 * @param devicePushNotificationToken
 *            The device push notification token if the 3rd paryt need support notification for Moxtra client.
 * @param success
 *            Callback interface for notifying the calling application when
 *            setup user successed.
 * @param failure
 *            Callback interface for notifying the calling application when
 *            setup user failed.
 */
- (void)initializeUserAccount:(MXUserIdentity*)userIdentity
                        orgID:(NSString*)orgID
                    firstName:(NSString*)firstName
                     lastName:(NSString*)lastName
                       avatar:(UIImage*)avatar
  devicePushNotificationToken:(NSData*)deviceToken
                      success:(void(^)())success
                      failure:(void(^)(NSError*error))failure;


#pragma mark update user's profile
/**
 * If user need update their profile, you can call this API to update them.
 *
 * @param firstName
 *            User's firstName.
 * @param lastName
 *            User's lastName.
 * @param avatar
 *            User's avatar image. If need we will resize it according to the image size.
 * @param success
 *            Callback interface for notifying the calling application when
 *            update user's profile successed.
 * @param failure
 *            Callback interface for notifying the calling application when
 *            update user's profile failed.
 */
- (void)updateUserProfile:(NSString*)firstName
                 lastName:(NSString*)lastName
                   avatar:(UIImage*)avatar
                  success:(void(^)())success
                  failure:(void(^)(NSError *error))failure;


#pragma mark chat SDK
/**
 * Get chat array. The object in the array is MXChatSession.
 */
- (NSArray*)getChatSessionArray;


/**
 * Create a new chat.
 *
 * @param topic
 *            The topic of the chat. The default topic is made up of the chat members' name.
 * @param uniqueIDArray
 *            The user's unique ID array that you want to invite to join.
 * @param success
 *            Callback interface for notifying the calling application when
 *            create chat successed.
 * @param failure
 *            Callback interface for notifying the calling application when
 *            create chat failed.
 */
- (void)createChat:(NSString*)topic
  inviteMembersUniqueID:(NSArray*)uniqueIDArray
                success:(void(^)(NSString*binderID, UIViewController*chatViewController))success
                failure:(void(^)(NSError*error))failure;


/**
 * Delete a chat.
 *
 * @param binderID
 *            The binder id that identify the chat.
 * @param success
 *            Callback interface for notifying the calling application when
 *            delete chat successed.
 * @param failure
 *            Callback interface for notifying the calling application when
 *            delete chat failed.
 */
- (void)deleteChat:(NSString*)binderID
           success:(void(^)())success
           failure:(void(^)(NSError*error))failure;


/**
 * Create a chat view controller via chat session id and return it.
 * Return nil if can not find the chat via the binderID.
 *
 * @param binderID
 *            The binder id that identify the chat.
 */
- (UIViewController*)getChatViewController:(NSString*)binderID;


/**
 * Invite members to join chat.
 *
 * @param uniqueIDArray
 *            The user's unique ID array.
 * @param binderID
 *            The binder id of the chat that you want to invite members to join.
 * @param success
 *            Callback interface for notifying the calling application when
 *            invite members successed.
 * @param failure
 *            Callback interface for notifying the calling application when
 *            invite members failed.
 */
- (void)inviteChatMembers:(NSArray*)uniqueIDArray
                 binderID:(NSString*)binderID
                  success:(void(^)())success
                  failure:(void(^)(NSError *error))failure;


/**
 * Invite attendees to join meet.
 *
 * @param uniqueIDArray
 *            The user's unique ID array.
 * @param success
 *            Callback interface for notifying the calling application when
 *            invite attendees successed.
 * @param failure
 *            Callback interface for notifying the calling application when
 *            invite attendees failed.
 */
- (void)inviteMeetAttendees:(NSArray*)uniqueIDArray
                    success:(void(^)())success
                    failure:(void(^)(NSError *error))failure;


/**
 * Import files to current chat.
 * 3rd party can call this API in the delegate method presentAddFilesViewController or presentMoreFilesViewController.
 */
- (void)importFilesWithFilePathArray:(NSArray*)filePathArray;


/**
 * 3rd party notification support
 *
 * Update device push notification token if the 3rd paryt need support remote notification for Moxtra client.
 * You should call this API in UIApplicationDelegate - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
 */
- (void)updateRemoteNotificationsWithDeviceToken:(NSData*)deviceToken;

/**
 * Handle the remote notification if the 3rd paryt need support remote notification for Moxtra client.
 * Reture NO if Moxtra client could not handle the remote notification.
 * You should call this API in UIApplicationDelegate - (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
 */
- (BOOL)receiveRemoteNotificationWithUserInfo:(NSDictionary*)userInfo;

/**
 * Handle the remote notification if the 3rd paryt need support remote notification for Moxtra client.
 * Reture NO if Moxtra client could not handle the remote notification.
 * You should call this API in UIApplicationDelegate - (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
 */
- (BOOL)receiveRemoteNotificationWithUserInfo:(NSDictionary*)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler;

/**
 * You should call this API to set the app badge number with the 3rd party's badge number in UIApplicationDelegate - (void)applicationDidEnterBackground:(UIApplication *)application
 * We will set app badge number in this API (3rd party's badge number + Moxtra's badge number)
 */
- (void)setBadgeNumberDidEnterBackground:(NSInteger)thirdPartyBadgeNumber;


#pragma mark unlink
/**
 * Unlink Moxtra account.
 */
- (void)unlinkAccount:(void(^)(BOOL success))completion;


#pragma mark other APIs
// User login status
- (BOOL)isUserLoggedIn;

// User info
- (MXChatMemberInfo*)getUserInfo;

@end
