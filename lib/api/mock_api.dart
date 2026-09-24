import 'dart:math';

import '../models/models.dart';
import 'kugou_api.dart';

/// 假数据实现：用内置数据跑通 UI，接口形状与真实酷狗 API 对齐，
/// 后续切 [HttpKugouApi] 时页面层无需改动。
class MockKugouApi implements KugouApi {
  MockKugouApi() {
    _songs = _baseSongs;
  }

  late List<Song> _songs;

  static const _baseSongs = <Song>[
    Song(name: '晴天', artist: '周杰伦', album: '叶惠美', duration: Duration(minutes: 4, seconds: 29)),
    Song(name: '起风了', artist: '买辣椒也用券', album: '起风了', duration: Duration(minutes: 5, seconds: 23)),
    Song(name: '孤勇者', artist: '陈奕迅', album: '孤勇者', duration: Duration(minutes: 4, seconds: 16)),
    Song(name: '稻香', artist: '周杰伦', album: '魔杰座', duration: Duration(minutes: 3, seconds: 44)),
    Song(name: '晚安', artist: '颜人中', album: '晚安', duration: Duration(minutes: 4, seconds: 8)),
    Song(name: '消愁', artist: '毛不易', album: '平凡的一天', duration: Duration(minutes: 4, seconds: 30)),
    Song(name: '如愿', artist: '王菲', album: '如愿', duration: Duration(minutes: 4, seconds: 5)),
    Song(name: '漠河舞厅', artist: '柳爽', album: '漠河舞厅', duration: Duration(minutes: 5, seconds: 34)),
  ];

  static final _playlists = <Playlist>[
    Playlist(id: 'pl1', name: '华语经典必听', desc: '精选华语黄金年代金曲', playCount: 12480000, coverColor: gradientColor(0)),
    Playlist(id: 'pl2', name: '车载电音狂欢', desc: '开车必备嗨曲合集', playCount: 8660000, coverColor: gradientColor(1)),
    Playlist(id: 'pl3', name: '深夜情歌电台', desc: '一个人的夜晚慢慢听', playCount: 21030000, coverColor: gradientColor(2)),
    Playlist(id: 'pl4', name: '国语流行新歌速递', desc: '每周五更新', playCount: 5400000, coverColor: gradientColor(3)),
    Playlist(id: 'pl5', name: '经典粤语怀旧', desc: '致敬港乐黄金时代', playCount: 9210000, coverColor: gradientColor(4)),
    Playlist(id: 'pl6', name: '轻音乐·减压专享', desc: '放松身心纯音乐', playCount: 7750000, coverColor: gradientColor(5)),
    Playlist(id: 'pl7', name: '摇滚现场精选', desc: '躁起来就完事了', playCount: 4880000, coverColor: gradientColor(6)),
    Playlist(id: 'pl8', name: '怀旧金曲8090', desc: '那些年我们一起听歌', playCount: 13300000, coverColor: gradientColor(7)),
  ];

  static final _ranks = <RankCategory>[
    const RankCategory(name: '酷狗TOP500', desc: '最热歌曲实时更新'),
    const RankCategory(name: '飙升榜', desc: '上升最快的新热歌'),
    const RankCategory(name: '新歌榜', desc: '最新发行好歌'),
    const RankCategory(name: '原创榜', desc: '原创音乐人作品'),
    const RankCategory(name: '热歌飙升', desc: '抖音热歌风向标'),
    const RankCategory(name: 'DJ热舞榜', desc: '节奏炸裂舞曲'),
    const RankCategory(name: '华语榜', desc: '华语歌曲权威排名'),
    const RankCategory(name: '欧美榜', desc: 'Billboard风格精选'),
  ];

  static final _albums = <Album>[
    Album(id: 'al1', name: '叶惠美', artist: '周杰伦', publishTime: '2003', trackCount: 11, coverColor: gradientColor(0)),
    Album(id: 'al2', name: '七里香', artist: '周杰伦', publishTime: '2004', trackCount: 10, coverColor: gradientColor(1)),
    Album(id: 'al3', name: '十一月的萧邦', artist: '周杰伦', publishTime: '2005', trackCount: 12, coverColor: gradientColor(2)),
    Album(id: 'al4', name: '魔杰座', artist: '周杰伦', publishTime: '2008', trackCount: 11, coverColor: gradientColor(3)),
    Album(id: 'al5', name: '跨时代', artist: '周杰伦', publishTime: '2010', trackCount: 11, coverColor: gradientColor(4)),
  ];

  static const _hot = ['夏天的风', '乌梅子酱', '爱如火', '向云端', '我记得', '迟到千年', '巴合提的春天', '人和人的相遇'];

  // —— 统一模拟网络延迟 ——
  Future<void> _delay([int ms = 240]) => Future.delayed(Duration(milliseconds: ms));

  @override
  Future<bool> loginPhone(String phone, String code) async {
    await _delay(400);
    return phone.length == 11 && code.isNotEmpty;
  }

  @override
  Future<List<String>> hotSearch() async {
    await _delay();
    return _hot;
  }

  @override
  Future<List<Song>> search(String keyword) async {
    await _delay(300);
    final kw = keyword.trim();
    if (kw.isEmpty) return _songs;
    return _songs.where((s) => s.name.contains(kw) || s.artist.contains(kw)).toList();
  }

  @override
  Future<String?> songUrl(Song song) async {
    await _delay(100);
    return null; // mock 不返回真实地址
  }

  @override
  Future<String?> songClimax(Song song) async {
    await _delay(100);
    return null;
  }

  @override
  Future<List<LyricLine>> lyric(Song song) async {
    await _delay(200);
    const raw = [
      '故事的小黄花',
      '从出生那年就飘着',
      '童年的荡秋千',
      '随记忆一直晃到现在',
      '刮风这天 我试过握着你手',
      '但偏偏 雨渐渐 大到我看你不见',
      '还要多久 我才能在你身边',
      '等到放晴的那天 也许我会比较好一点',
      '从前从前 有个人爱你很久',
      '但偏偏 风渐渐 把距离吹得好远',
    ];
    return [
      LyricLine(Duration.zero, song.name),
      for (var i = 0; i < raw.length; i++)
        LyricLine(Duration(seconds: 20 + i * 8), raw[i]),
    ];
  }

  @override
  Future<List<Playlist>> recommendPlaylists() async {
    await _delay();
    return _playlists.take(5).toList();
  }

  @override
  Future<List<Song>> playlistTracks(Playlist playlist) async {
    await _delay();
    return _songs;
  }

  @override
  Future<List<RankCategory>> rankCategories() async {
    await _delay();
    return _ranks;
  }

  @override
  Future<List<Song>> rankSongs(RankCategory category) async {
    await _delay();
    return _songs;
  }

  @override
  Future<List<Song>> dailyRecommend() async {
    await _delay();
    return _songs;
  }

  @override
  Future<List<Song>> favoriteSongs() async {
    await _delay();
    return _songs.take(5).toList();
  }

  @override
  Future<Song> fmNext() async {
    await _delay(180);
    return _songs[Random().nextInt(_songs.length)];
  }

  @override
  Future<List<Playlist>> fmScenes() async {
    await _delay();
    return [
      Playlist(id: 'sc1', name: '清晨唤醒', desc: '驾车通勤', coverColor: gradientColor(0)),
      Playlist(id: 'sc2', name: '雨天氛围', desc: '安静陪伴', coverColor: gradientColor(1)),
      Playlist(id: 'sc3', name: '运动节拍', desc: '供应能量', coverColor: gradientColor(2)),
      Playlist(id: 'sc4', name: '睡前助眠', desc: '轻柔入梦', coverColor: gradientColor(3)),
      Playlist(id: 'sc5', name: '咖啡馆', desc: '慢时光', coverColor: gradientColor(4)),
      Playlist(id: 'sc6', name: '派对模式', desc: '燃爆全场', coverColor: gradientColor(5)),
    ];
  }

  @override
  Future<List<Song>> albumTracks(Album album) async {
    await _delay();
    return _songs.take(6).toList();
  }

  @override
  Future<List<Song>> artistSongs(Artist artist) async {
    await _delay();
    return _songs;
  }

  @override
  Future<List<Album>> artistAlbums(Artist artist) async {
    await _delay();
    return _albums;
  }

  @override
  Future<void> registerDev() async {
    await _delay(50);
  }

  @override
  Future<String?> getModel() async {
    return 'mock-model';
  }
}
