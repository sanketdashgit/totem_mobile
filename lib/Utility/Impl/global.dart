import 'package:get/get.dart';
import 'package:totem_app/Controller/RequestController.dart';
import 'package:totem_app/Models/SuggestedUsersModel.dart';
import 'package:totem_app/Utility/Annotation/todo.dart';

RequestController rq = Get.put(RequestController(), permanent: true);

@todo('App preferences keys i.e session keys')
// ignore: camel_case_types
class sessionKeys {
  static var sbStore = "sb_preference";
  static var keyFirstTimeUser = "first_time_user";
  static var keyShowIntroScreen = "show_intro_screen";
  static var keyLogin = "_sb_login";
  static var keyLoginToken = "_sb_login_token";
  static var keyLoginProfile = "_sb_login_profile";
  static var keyLoginID = "_sb_login_id";
  static var keyisPrivate = "_sb_privacy";
  static var keyLoginFirstName = "_sb_login_fname";
  static var keyLoginLastName = "_sb_login_lname";
  static var keyLoginEmail = "_sb_login_email";
  static var keyLoginBD = "_sb_login_bd";
  static var keyLoginUname = "_sb_login_uname";
  static var KeyLoginPhone = "_sb_login_phone";
  static var KeySpotifyToken = "_sb_spotify_token";
  static var KeyFCMToken = "_sb_fcm_token";
  static var KeyToken = "_sb_token";
  static var KeyIntro1 = "_sb_intro1";
  static var KeyIntro2 = "_sb_intro2";
  static var KeyIntro3 = "_sb_intro3";
  static var KeyIntro4 = "_sb_intro4";
  static var KeyIntro5 = "_sb_intro5";
  static var KeyIntro6 = "_sb_intro6";
  static var KeyIntro7 = "_sb_intro7";
  static var KeyIntro8 = "_sb_intro8";
  static var KeyIntro9 = "_sb_intro9";
  static var KeyIntro10 = "_sb_intro10";
}

@todo('App Constants')
// ignore: camel_case_types
class global {
  static const appName = 'Totam';
  static const signIn = 'Sign In';

  static const REQUEST_MAX_TIMEOUT = 100;
  static const POST_THRESOLD_VALUE = 100;
  static const POST_IMAGE_THRESOLD_VALUE = 5;
  static const POST_VIDEO_THRESOLD_VALUE = 15;
  static const int PAGE_SIZE = 5;
  static const int PAGE_SIZE_EXPLORE = 10;
  static const String MEDIA_IMAGE_TYPE = "IMAGE";
  static const String MEDIA_VIDEO_TYPE = "VIDEO";
  static const String NOTIFICATION_POST_TYPE = "POST";
  static const String NOTIFICATION_FOLLOW_REQUEST_TYPE = "FOLLOW_REQUEST";
  static const String NOTIFICATION_FOLLOW_TYPE = "FOLLOW";
  static const String NOTIFICATION_COMMENT_TYPE = "COMMENT";
  static const String NOTIFICATION_LIKE_TYPE = "LIKEPOST";

  static const String Android_AD_Id = "ca-app-pub-6510884247700598~7373444285";
  static const String Android_AD_Native_Unit_Id = "ca-app-pub-6510884247700598/3949204599";
}

@todo('Server Request Main URL/Server RequestCode or Post url')
// ignore: camel_case_types
class endPoints {
  //static var baseUrl = 'https://35.231.45.54:4445/';
  static var baseUrl = 'https://api.totemapp.org/';

  static const signUp = 'api/Mobile_Account/CreateAccount';
  static const signIn = 'api/Mobile_Account/Login';
  static const forgotPwd = 'api/Mobile_Account/ForgetPassword';
  static const profileImageUpload = 'api/Mobile_Account/ProfileImageUpload';
  static const checkMailExist = 'api/Mobile_Account/CheckMailExist';
  static const updateUser = 'api/Mobile_Account/UpdateUser';
  static const getAllUsers = 'GetAllUsers';
  static const GetAllExploreUsers = 'GetAllExploreUsers';
  static const TagAllFollowerList = 'TagAllfollow';
  static const GetTagUserofPost = 'api/post/GetTagUserofPost';
  static const UpdatedGetAllUsers = 'UpdatedGetAllUsers';
  static const follow = 'Follow';
  static const getAllfollow = 'GetAllfollow';
  static const getAllfollower = 'GetAllfollower';
  static const getfollowerRequest = 'GetfollowerRequest';
  static const GetfollowerCount = 'GetfollowerCount';
  static const deleteSuggested = 'Deletesuggested';
  static const approveFollow = 'ApproveFollow';
  static var kGoogleApiKey = 'AIzaSyBprJaLdHXBMMVlG37ShgId_EQ_-Bzo9qE';//'AIzaSyCS-TOYShBWX-pXn5AMhm5ihE5NJ2UE0eI';//'AIzaSyBprJaLdHXBMMVlG37ShgId_EQ_-Bzo9qE';
  static const createEvent = 'api/Event/CreateEvent';
  static const eventFileUpload = 'api/Event/EventFileUpload';
  static const getByEventID = 'api/Event/GetByEventID';
  static const addEventInterest = 'api/Event/AddEventFeed';
  static const getAllEvent = 'api/Event/GetAllEvent';
  static const getAllEventByPost = 'api/Event/GetAllByPostEvent';
  static const createEventByPost = 'api/Event/CreateEventByPost';
  static const saveSpotify = 'api/Mobile_Account/Spotify';
  static const getSpotify = 'api/Mobile_Account/GetSpotify';
  static const favSongs = 'api/Mobile_Account/FavSongs';
  static const getFavSongs = 'api/Mobile_Account/GetFavSongs';
  static const profileVerifyReq = 'api/Mobile_Account/ProfileVerifyReq';
  static const businessUserReq = 'api/Mobile_Account/BusinessUserReq';
  static const addEditPost = 'api/post/addeditpost';
  static const addEditMemories = 'api/post/addeditMemorie';
  static const CreateMemorieWithFiles = 'api/post/CreateMemorieWithFiles';
  static const uploadPostImage = 'api/post/addpostfiles';
  static const UpdatedAddEditpost = 'api/post/UpdatedAddEditpost';
  static const uploadMemoriesFiles = 'api/post/addMemoriefiles';
  static const addEventComment = 'api/Event/AddCommentOnEvent';
  static const addEventReplyOnComment = 'api/Event/UpdateCommentReply';
  static const getEventComments = 'api/Event/GetEventComments';
  static const LikeOnEventComments = 'api/Event/CreateLikeoncomment';
  static const EditPrivacy = 'api/Mobile_Account/EditPrivacy';
  static const getUserListByEventType = 'api/Event/GetUserListByEventType';
  static const ChangePassword = 'api/Mobile_Account/ChangePassword';
  static const AddSupport = 'api/Event/AddSupport';
  static const GetFeedList = 'api/post/GetUserPostFeeds';
  static const GetPostTopCountFeeds = 'api/post/GetPostTopCountFeeds';
  static const GetALLPostTopCount = 'api/post/GetALLPostTopCount';
  static const GetExplorePost = 'api/post/GetExplorePost';
  static const getNextEvent = 'api/Event/GoNextEvent';
  static const removeEvent = 'api/Event/RemoveEvent';
  static const editPostPrivacy = 'api/post/EditPostPrivacy';
  static const removepostmedia = 'api/post/removepostmedia';
  static const deletepost = 'api/post/deletepost';
  static const likepost = 'api/post/likepost';
  static const LikePostFiles = 'api/post/LikePostFiles';
  static const addComment = 'api/post/addcomment';
  static const reportOnPost = 'api/post/BlockPost';
  static const GetComments = 'api/post/GetComments';
  static const InsertPostCommentsReply = 'api/post/InsertPostCommentsReply';
  static const BlockUser = 'api/Mobile_Account/BlockUser';
  static const GetBlockuser = 'api/Mobile_Account/GetBlockuser';
  static const GetPostbyPostId = 'api/post/GetPostbyPostId';
  static const GetpostLikesUsers = 'api/post/GetpostLikesUsers';
  static const GetUsersPost = 'api/post/getuserposts';
  static const GetUserMemories = 'api/post/getusermemories';
  static const GetAllUserStatus = 'api/Mobile_Account/GetAllUserStatus';
  static const Deleteuser = 'api/Mobile_Account/Deleteuser';
  static const ResendMailverify = 'api/Mobile_Account/ResendMailverify';
  static const GetNotification = 'api/Mobile_Account/GetNotification';
  static const ClearNotification = 'api/Mobile_Account/ClearNotification';
  static const ConfigNotification = 'api/Mobile_Account/ConfigNotefication';
  static const LogoutFCM = 'api/Mobile_Account/LogoutFCM';
  static const GetFCMToken = 'api/Mobile_Account/GetFCMDetails';
  static const InvalidLoginAttempts = 'api/Mobile_Account/InvalidLoginAttempts';
  static const PresentLiveStatus = 'api/Mobile_Account/PresentLiveStatus';
  static const RemoveTagOfPost = 'api/post/RemoveTagofPost';
  static const PostTagRequestAccept = 'api/post/PostTagRequestAccept';
  static const RemoveComments = 'api/post/RemoveComments';
  static const RemoveReplyComments = 'api/post/RemoveCommentsReply';
  static const RemoveEventComments = 'api/Event/RemoveEventComments';
  static const RemoveEventCommentReply = 'api/Event/RemoveEventCommentReply';
  static const GetAllUpcomingEvent = 'api/Event/GetAllUpcomingEvent';
  static const CreateEventwithvanueId = 'api/Event/CreateEventwithvanueId';
  static const DeleteMemoriesFiles = 'api/post/DeleteMemoriesFiles';
  static const editMemoryPrivacy = 'api/post/editMemorieprivacy';
  static const editMemoryFilePrivacy = 'api/post/editMemorieFileprivacy';
  static const getUpdatedVersion = 'api/Mobile_Account/GetUpdatedVersion';
  static const testingPathReturn = 'api/Event/TestingPathReturn';
  static const getTopSongs = 'api/Mobile_Account/GetTopSongs';
  static const getTopSpotify = 'api/Mobile_Account/GetTopSpotify';
}

@todo('App Measurement in Logical Pixels')
// ignore: camel_case_types
class dimen {
  //fontSize
  static const textExtraSmall = 8.0;
  static const textMidSmall = 10.0;
  static const textSmall = 12.0;
  static const textSemiNormal = 13.0;
  static const textNormal = 14.0;
  static const textMedium = 16.0;
  static const textExtraMedium = 18.0;
  static const textLarge = 20.0;
  static const textExtraLarge = 24.0;

  //padding
  static const paddingForBackArrow = 4.0;
  static const paddingTiny = 2.0;
  static const paddingVerySmall = 4.0;
  static const paddingSmall = 8.0;
  static const paddingMedium = 12.0;
  static const paddingLarge = 16.0;
  static const paddingExtraLarge = 20.0;
  static const paddingBig = 24.0;
  static const paddingBigLarge = 30.0;
  static const paddingExtra = 50.0;
  static const paddingXLarge = 70.0;
  static const paddingXXLarge = 90.0;
  static const paddingForTab = 60.0;
  static const paddingNavigationBar = 120.0;

  //Sizes
  static const smallIconSize = 14.0;
  static const verifiedIconSize = 18.0;
  static const hamburgerIconSize = 28.0;
  static const tabIconSize = 22.0;
  static const iconSize = 22.0;
  static const iconButtonSize = 38.0;
  static const buttonHeight = 40.0;
  static const formTextFieldHeight = 55.0;
  static const formLargeTextFieldHeight = 80.0;
  static const searchBarHeight = 45.0;
  static const containerSizeSmall = 70.0;
  static const appBarHeight = 42.0;

  //corners
  static const radiusVerySmall = 2.0;
  static const radiusSmall = 4.0;
  static const radiusMedium = 8.0;
  static const radiusNormal = 14.0;
  static const radiusLarge = 18.0;

//  Margin
  static const marginLarge = 22.0;
  static const marginSmall = 8.0;
  static const marginVerySmall = 4.0;
  static const marginNormal = 12.0;
  static const marginMedium = 16.0;
  static const marginExtraMedium = 20.0;
  static const marginHues = 30.0;
  static const marginExtraHues = 36.0;

//  Divider height
  static const dividerHeightVerySmall = 4.0;
  static const dividerHeightSmall = 8.0;
  static const dividerHeightNormal = 12.0;
  static const dividerHeightMedium = 16.0;
  static const dividerHeightLarge = 22.0;
  static const dividerHeightHuge = 26.0;
  static const dividerHeightXLarge= 40.0;

  //Appbar icon size
  static const sliverAppTopBarHeight = 260.0;
  // static const sliverFullAppBarHeight = 470.0;
  static const sliverFullAppBarHeight = 470.0;
  static const appBarActionIconHeight = 20.0;
  static const appBarActionIconWidth = 20.0;
  static const navigationBarIconHeight = 26.0;
  static const navigationBarIconWidth = 28.0;

  // Add new post image height
  static const newPostImageHeight = 250.0;

  //user related
  static const profileIconHeightSmall = 26.0;
  static const profileIconWidthSmall = 26.0;
  static const profileIconHeightLarge = 46.0;
  static const profileIconWidthLarge = 46.0;
  static const profileIconHeightExtraLarge = 54.0;
  static const profileIconWidthExtraLarge = 54.0;
}

@todo('Global Variables : While communicate with server.')
class LogicalComponents {
  static SuggestedUsersModel suggestedUsersModel = SuggestedUsersModel();
}
