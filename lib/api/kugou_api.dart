import '../models/models.dart';

/// 酷狗 API 服务抽象层。
///
/// 当前阶段用 [MockKugouApi]（假数据）跑通 UI；
/// 上真机时实现 [HttpKugouApi]（dio 指向内嵌 .so 暴露的 127.0.0.1 端口）。
/// 覆盖选定接口分组：1 登录 / 2 搜索 / 3 播放 / 4 歌词 / 5 歌单 /
/// 6 榜单 / 7 每日推荐 / 8 个人中心 / 9 私人FM / 10 专辑 / 11 歌手 / 24 基础设施。
abstract class KugouApi {
  // 分组 1：登录
  Future<bool> loginPhone(String phone, String code);

  // 分组 2：搜索
  Future<List<String>> hotSearch();
  Future<List<Song>> search(String keyword);

  // 分组 3：播放
  Future<String?> songUrl(Song song); // 返回播放地址，mock 返回 null
  Future<String?> songClimax(Song song); // 高潮片段，mock 返回 null

  // 分组 4：歌词
  Future<List<LyricLine>> lyric(Song song);

  // 分组 5：歌单
  Future<List<Playlist>> recommendPlaylists();
  Future<List<Song>> playlistTracks(Playlist playlist);

  // 分组 6：榜单
  Future<List<RankCategory>> rankCategories();
  Future<List<Song>> rankSongs(RankCategory category);

  // 分组 7：每日推荐
  Future<List<Song>> dailyRecommend();

  // 分组 8：个人中心
  Future<List<Song>> favoriteSongs();

  // 分组 9：私人FM
  Future<Song> fmNext();
  Future<List<Playlist>> fmScenes();

  // 分组 10：专辑
  Future<List<Song>> albumTracks(Album album);

  // 分组 11：歌手
  Future<List<Song>> artistSongs(Artist artist);
  Future<List<Album>> artistAlbums(Artist artist);

  // 分组 24：基础设施（注册设备/取机型，mock 空实现）
  Future<void> registerDev();
  Future<String?> getModel();
}
