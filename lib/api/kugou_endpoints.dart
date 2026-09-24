/// 内嵌酷狗 API 服务器（libkugou_server.so）的接口路径。
///
/// 与 MD3Music 的 kugou_endpoints.dart 对齐，但只保留 [KugouApi]
/// 抽象层实际用到的路径，避免引入无用常量。
class KugouEndpoints {
  KugouEndpoints._();

  /// 默认 API 服务地址。本地服务器启动成功后由 KugouApiServer
  /// 用实际随机端口覆盖为 `http://127.0.0.1:<port>`。
  static String baseUrl = 'http://127.0.0.1:8080';

  // —— 登录 ——
  static const String loginCellphone = '/login/cellphone';

  // —— 搜索 ——
  static const String search = '/search';
  static const String searchHot = '/search/hot';
  static const String searchLyric = '/search/lyric';

  // —— 歌曲 ——
  static const String songUrl = '/song/url';
  static const String songClimax = '/song/climax';

  // —— 歌词 ——
  static const String lyric = '/lyric';

  // —— 歌单 ——
  static const String playlistDetail = '/playlist/detail';
  static const String playlistTrackAll = '/playlist/track/all';

  // —— 榜单 ——
  static const String rankList = '/rank/list';
  static const String rankAudio = '/rank/audio';

  // —— 每日推荐 ——
  static const String everydayRecommend = '/everyday/recommend';

  // —— 私人 FM ——
  static const String personalFm = '/personal/fm';

  // —— 场景（FM 场景卡片）——
  static const String sceneLists = '/scene/lists';

  // —— 专辑 ——
  static const String albumDetail = '/album/detail';
  static const String albumSongs = '/album/songs';

  // —— 歌手 ——
  static const String artistAlbums = '/artist/albums';
  static const String artistAudios = '/artist/audios';

  // —— 基础设施 ——
  static const String registerDev = '/register/dev';
  static const String getModel = '/get/model';
}
