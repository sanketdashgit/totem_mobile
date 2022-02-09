import 'package:get/get.dart';
import 'package:totem_app/GeneralUtils/FlickMultiManager.dart';
import 'package:totem_app/Models/ArtistModel.dart';
import 'package:totem_app/Models/ArtistTotemModel.dart';
import 'package:totem_app/Models/EventHomeModel.dart';
import 'package:totem_app/Models/ExploreMedia.dart';
import 'package:totem_app/Models/FeedListDataModel.dart';
import 'package:totem_app/Models/OpenProfileNeddDataModel.dart';
import 'package:totem_app/Models/PostCommentModel.dart';
import 'package:totem_app/Models/SearchEventModel.dart';
import 'package:totem_app/Models/EventDetailsModel.dart';
import 'package:totem_app/Models/SelectMediaModel.dart';
import 'package:totem_app/Models/SongTotemModel.dart';
import 'package:totem_app/Models/SuggestedUsersModel.dart';
import 'package:totem_app/Models/TrackModel.dart';
import 'package:totem_app/Utility/Annotation/todo.dart';

@todo('State Management for Web Responses')
class RequestController extends GetxController {
  var userId = 0.obs;
  var userFname = ''.obs;
  var userLname = ''.obs;
  var getFAQdata = [].obs;
  var isEdit = false.obs;

//  For create event
  var createEventName = ''.obs;
  var createEventStartDate = ''.obs;
  var createEventStartTime = ''.obs;
  var createEventEndDate = ''.obs;
  var createEventEndTime = ''.obs;
  var startDate = ''.obs;
  var endDate = ''.obs;
  var createEventAddressVenue = ''.obs;
  var createEventLat = 0.0.obs;
  var createEventLong = 0.0.obs;
  var createEventCity = ''.obs;
  var createEventState = ''.obs;
  var createEventDetails = ''.obs;
  var createEventImage = ''.obs;
  var createEventImage1 = ''.obs;
  var createEventImage2 = ''.obs;
  var phoneNumber = ''.obs;

  Rx<EventHomeModel> eventDetails = EventHomeModel().obs;
  var isEditEvent = false.obs;
  var coverUrl = ''.obs;
  var mapUrl = ''.obs;
  var lineupUrl = ''.obs;
  var editEventIndex = 0;

  var createEventEnable = true.obs;

  List<String> selectedGener = [];
  List<ArtistTotemModel> selectedArtist = [];
  List<SongTotemModel> selectedTracks = [];
  List<EventHomeModel> selectedEvents = [];
  List<EventHomeModel> nextEvents = [];

  List<dynamic> pickedImageList = [];
  List<SelectMediaModel> pickedMediaList = [];

  //for explore people
  var searchText = "".obs;
  List<ExploreMedia> postMediaLinks = [];
  List<OpenProfileNeedDataModel> postExtraInfo = [];

  //for event list
  List<EventHomeModel> eventList = [];
  List<FeedListDataModel> homeFeedList = [];
  List<FeedListDataModel> homeList = [];
  List<FeedListDataModel> otherFeedList = [];
  List<FeedListDataModel> homeFeedDeepLink = [];
  var widgetRefresher = ''.obs;
  var widgetRefresherDeeplink = ''.obs;

  // Post comment
  List<PostCommentModel> postCommentList = [];
  var postCommentWidgetRefresher = "".obs;
  var imagePageRefrasher = "".obs;
  List<int> removedList = [];

  // For chat Notification
  bool isChatDetailOpen = false;
  String conversationID = '';

  FlickMultiManager flickMultiManager =  FlickMultiManager();

//  for hiding floating brn in home page
  var isShowFloatBtn = true.obs;


  List<SuggestedUser> tagPeopleList = [];
  List<int> tagPeopleSelectedIds = [];
  var tagPeopleCount = ''.obs;

//  For tag event info
  var selectedEventId = 0.obs;
  var selectedEventName = ''.obs;
  var selectedEventAdd = ''.obs;
  var selectedEventImg = ''.obs;

  //refer id
  var referId = 0;
}
