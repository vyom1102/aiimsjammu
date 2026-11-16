import 'API/CategoryAPI.dart';
import 'API/ExhibitorsAPI.dart';
import 'API/SessionsAPI.dart';
import 'API/SubEventsAPI.dart';
import 'APIModel/CardData.dart';
import 'APIModel/CategoryModel.dart';
import 'APIModel/ExhibitorModel.dart';
import 'APIModel/SessionModel.dart';
import 'APIModel/SubEventsModel.dart';
import 'ConferenceMapper.dart';

class EventsState {
  // Singleton instance
  static final EventsState _instance = EventsState._internal();
  factory EventsState() => _instance;

  EventsState._internal() {
    // ✅ This code runs once when the singleton is first created
    _init();
  }

  Map<String,List<CardData>>? groupedDataByVenue;

  Conferencemapper conferencemapper = Conferencemapper();

  Categorymodel? _categoryData;
  Future<Categorymodel?>? _categoryDataFuture;

  SessionModel? _sessionData;
  Future<SessionModel?>? _sessionDataFuture;

  SubEventsModel? _subEventsData;
  Future<SubEventsModel?>? _subEventsDataFuture;

  List<ExhibitorModel>? _exhibitorData;
  Future<List<ExhibitorModel>?>? _exhibitorDataFuture;

  Future<void> _init() async {
    // Perform startup functionality here
    print("EventsState initialized!");

    // Example: prefetch data
    // await fetchCategory();
    // await fetchSession();
    // await fetchSubEvents();
    // await fetchExhibitors();
    // groupedDataByVenue = groupSubEventsByLandmark(categoryData: _categoryData, sessionData: _sessionData, subEventsData: _subEventsData);
    // print("EventsState completed groupedDataByVenue $groupedDataByVenue");
  }

  /// Generic caching helper
  Future<T?> _cache<T>(
      T? cached,
      Future<T?>? future,
      Future<T> Function() fetcher,
      void Function(T) setter,
      ) {
    if (cached != null) return Future.value(cached);
    if (future != null) return future;

    final f = fetcher().then((value) {
      if (value != null) setter(value);
      return value;
    });

    return f;
  }

  /// Fetch or return cached Category
  Future<Categorymodel?> fetchCategory({bool refresh = false}) {
    if (refresh) {
      _categoryData = null;
      _categoryDataFuture = null;
    }
    return _cache<Categorymodel>(
      _categoryData,
      _categoryDataFuture,
          () => Categoryapi().fetchCategory(),
          (c) => _categoryData = c,
    );
  }

  Future<SessionModel?> fetchSession({bool refresh = false}) {
    if (refresh) {
      _sessionData = null;
      _sessionDataFuture = null;
    }
    return _cache<SessionModel>(
      _sessionData,
      _sessionDataFuture,
          () => Sessionsapi().fetchSession(),
          (c) => _sessionData = c,
    );
  }

  Future<SubEventsModel?> fetchSubEvents({bool refresh = false}) {
    if (refresh) {
      _subEventsData = null;
      _subEventsDataFuture = null;
    }
    return _cache<SubEventsModel>(
      _subEventsData,
      _subEventsDataFuture,
          () => Subeventsapi().fetchSubEvents(),
          (c) => _subEventsData = c,
    );
  }

  Future<List<ExhibitorModel>?> fetchExhibitors({bool refresh = false}) {
    if (refresh) {
      _exhibitorData = null;
      _exhibitorDataFuture = null;
    }
    return _cache<List<ExhibitorModel>>(
      _exhibitorData,
      _exhibitorDataFuture,
          () => Exhibitorsapi().fetchExhibitor(),
          (c) => _exhibitorData = c,
    );
  }

  Map<String, List<CardData>>? groupSubEventsByLandmark({
    required Categorymodel? categoryData,
    required SessionModel? sessionData,
    required SubEventsModel? subEventsData,
  }) {
    if(categoryData == null || sessionData == null || subEventsData == null) return null;

    final result = <String, List<CardData>>{};

    for (var event in subEventsData.data!) {
      if(event.sessionId == null) continue;
      var sessions = sessionData.data?.where((session)=> session.sId == event.sessionId);
      if(sessions == null || sessions.isEmpty){
        continue;
      }
      var session = sessions.first;
      if(session.location?.sId != null){
        // group by landmarkId
        result.putIfAbsent(session.location!.sId!, () => []).add(conferencemapper.mapSubEventToCard(event, session));
      }
    }
    print("result after mapping ${result.keys}");
    return result;
  }
}
