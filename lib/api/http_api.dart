import 'package:dio/dio.dart';

import '../models/models.dart';
import 'kugou_api.dart';
import 'kugou_endpoints.dart';

/// 真实酷狗 API 实现：dio 指向内嵌 libkugou_server.so 暴露的本地端口。
///
/// 字段映射对齐 MD3Music 的 KugouSongDetail.fromJson（酷狗多套返回结构，
/// 字段大小写/嵌套差异大，这里收敛为同一套解析）。
class HttpKugouApi implements KugouApi {
  HttpKugouApi({String? baseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? KugouEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
  }

  late final Dio _dio;

  // —— 通用请求 ——
  Future<Map<String, dynamic>?> _get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    try {
      final r = await _dio.get(path, queryParameters: query);
      if (r.statusCode == 200 && r.data is Map<String, dynamic>) {
        return r.data as Map<String, dynamic>;
      }
      return null;
    } on DioException {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _post(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? query,
  }) async {
    try {
      final r = await _dio.post(path, data: data, queryParameters: query);
      if (r.data is Map<String, dynamic>) {
        return r.data as Map<String, dynamic>;
      }
      return null;
    } on DioException {
      return null;
    }
  }

  // —— 数据抽取 ——
  /// 从响应里抽 list 节点（酷狗字段名不统一，逐个兜底）。
  List<dynamic> _listOf(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      for (final k in const [
        'lists', 'song_list', 'songlist', 'songs', 'list', 'info', 'items',
      ]) {
        final v = data[k];
        if (v is List) return v;
      }
    }
    return const [];
  }

  /// 响应 → 歌曲列表（核心字段映射）。
  List<Song> _songsFrom(dynamic json) {
    final data = json is Map<String, dynamic> ? (json['data'] ?? json) : json;
    final list = _listOf(data);
    return list
        .whereType<Map<String, dynamic>>()
        .map(_songFromJson)
        .where((s) => s.hash.isNotEmpty || s.name.isNotEmpty)
        .toList();
  }

  /// 单首歌曲字段映射（对齐 KugouSongDetail.fromJson 的核心字段集）。
  Song _songFromJson(Map<String, dynamic> j) {
    // 嵌套对象浅展开（/audio 等接口字段藏在 audio_info/album_info/song_info 里）。
    final merged = <String, dynamic>{};
    for (final k in const ['audio_info', 'albuminfo', 'song_info', 'base']) {
      final nested = j[k];
      if (nested is Map) {
        nested.forEach((key, value) => merged.putIfAbsent(key.toString(), () => value));
      }
    }
    merged.addAll(j);

    String str(dynamic v) => v?.toString() ?? '';

    // 歌手：singerinfo / Singers / authors 数组优先，否则标量字段兜底。
    String artist = '';
    for (final key in const ['singerinfo', 'Singers', 'singers', 'authors']) {
      final arr = merged[key];
      if (arr is List && arr.isNotEmpty) {
        final names = <String>[];
        for (final e in arr) {
          if (e is Map) {
            final n = str(e['name'] ?? e['author_name']);
            if (n.isNotEmpty) names.add(n);
          }
        }
        if (names.isNotEmpty) {
          artist = names.join('、');
          break;
        }
      }
    }
    if (artist.isEmpty) {
      artist = str(
        merged['author_name'] ??
            merged['SingerName'] ??
            merged['artist_name'] ??
            merged['singername'],
      );
    }

    var name = str(
      merged['songname'] ??
          merged['SongName'] ??
          merged['name'] ??
          merged['ori_audio_name'] ??
          merged['FileName'] ??
          merged['filename'],
    );
    // audio_name 是「歌手 - 歌名」合并格式，歌名缺失时拆出。
    if (name.isEmpty) {
      final mergedName = str(merged['audio_name']);
      if (mergedName.isNotEmpty) {
        final sep = mergedName.indexOf(' - ');
        if (sep > 0) {
          artist = artist.isEmpty ? mergedName.substring(0, sep) : artist;
          name = mergedName.substring(sep + 3);
        } else {
          name = mergedName;
        }
      }
    }

    final album = str(
      merged['album_name'] ??
          merged['AlbumName'] ??
          merged['albumname'] ??
          merged['albuminfo']?['name'],
    );

    final hash = str(
      merged['hash'] ??
          merged['FileHash'] ??
          merged['Hash128'] ??
          merged['SQFileHash'] ??
          merged['HQFileHash'],
    );

    // 时长单位不统一（秒/毫秒），>10000 视为毫秒。
    final rawDur = int.tryParse(
      str(
        merged['time_length'] ??
            merged['HQDuration'] ??
            merged['Duration'] ??
            merged['duration'] ??
            merged['timelength'],
      ),
    ) ??
        0;
    final seconds = rawDur > 10000 ? rawDur ~/ 1000 : rawDur;

    final cover = str(
      merged['sizable_cover'] ??
          merged['album_sizable_cover'] ??
          merged['Image'] ??
          merged['ImgUrl'] ??
          merged['img'] ??
          merged['pic'] ??
          merged['cover'],
    );

    final sqHash = merged['hash_flac'] ?? merged['SQHash'] ?? merged['sq_hash'];

    return Song(
      name: name.isEmpty ? '未知歌曲' : name,
      artist: artist.isEmpty ? '未知歌手' : artist,
      album: album,
      hash: hash,
      duration: Duration(seconds: seconds),
      coverUrl: cover.isEmpty ? null : cover,
      sq: sqHash != null,
    );
  }

  // —— 登录 ——
  @override
  Future<bool> loginPhone(String phone, String code) async {
    // 概念版手机登录：先注册设备拿 dfid，再发验证码/登录。此处只做基础调用，
    // 真机联调时按 login.rs 的入参契约校准。
    final r = await _post(
      KugouEndpoints.loginCellphone,
      data: {'phone': phone, 'code': code},
    );
    return r != null && (r['status'] == 1 || r['data'] != null || r['error_code'] == 0);
  }

  // —— 搜索 ——
  @override
  Future<List<String>> hotSearch() async {
    final r = await _get(KugouEndpoints.searchHot);
    final data = r?['data'] ?? r;
    final list = _listOf(data);
    return list
        .map((e) {
          if (e is String) return e;
          if (e is Map) {
            return (e['searchword'] ?? e['keyword'] ?? e['name'] ?? '').toString();
          }
          return '';
        })
        .where((e) => e.isNotEmpty)
        .toList();
  }

  @override
  Future<List<Song>> search(String keyword) async {
    final r = await _get(
      KugouEndpoints.search,
      query: {'keywords': keyword, 'page': 1, 'pagesize': 30, 'type': 'song'},
    );
    return _songsFrom(r);
  }

  // —— 播放 ——
  @override
  Future<String?> songUrl(Song song) async {
    if (song.hash.isEmpty) return null;
    final r = await _get(
      KugouEndpoints.songUrl,
      query: {'hash': song.hash.toLowerCase()},
    );
    final data = r?['data'] ?? r;
    if (data is Map<String, dynamic>) {
      final url = data['url'];
      if (url is String && url.isNotEmpty) return url;
      // 部分结构 url 在 data.play_url 或数组里
      if (url is List && url.isNotEmpty) return url.first.toString();
    }
    return null;
  }

  @override
  Future<String?> songClimax(Song song) async {
    if (song.hash.isEmpty) return null;
    final r = await _get(
      KugouEndpoints.songClimax,
      query: {'hash': song.hash.toLowerCase()},
    );
    final data = r?['data'] ?? r;
    if (data is Map<String, dynamic>) {
      final u = data['url'] ?? data['play_url'];
      if (u is String && u.isNotEmpty) return u;
    }
    return null;
  }

  // —— 歌词 ——
  @override
  Future<List<LyricLine>> lyric(Song song) async {
    if (song.hash.isEmpty) return [LyricLine(Duration.zero, song.name)];
    // 1) 搜歌词拿 lyricId / accesskey
    final sr = await _get(
      KugouEndpoints.searchLyric,
      query: {'hash': song.hash.toLowerCase(), 'man': 'yes'},
    );
    String? lyricId;
    String? accesskey;
    final candidates = sr?['candidates'];
    if (candidates is List && candidates.isNotEmpty) {
      final first = candidates.first as Map<String, dynamic>;
      lyricId = first['id']?.toString();
      accesskey = first['accesskey']?.toString();
    }
    if (lyricId == null) return [LyricLine(Duration.zero, song.name)];

    // 2) 拉歌词内容
    final lr = await _get(
      KugouEndpoints.lyric,
      query: {
        'id': lyricId,
        'fmt': 'lrc',
        'decode': 'true',
        if (accesskey != null) 'accesskey': accesskey,
      },
    );
    final data = lr?['data'] ?? lr;
    final content = data is Map<String, dynamic>
        ? (data['decodeContent'] ?? data['content'] ?? '').toString()
        : '';
    return _parseLrc(content, song.name);
  }

  /// 解析 LRC 文本 → LyricLine 列表（[mm:ss.xx]歌词）。
  List<LyricLine> _parseLrc(String lrc, String fallbackName) {
    final re = RegExp(r'\[(\d{1,2}):(\d{1,2})(?:\.(\d{1,3}))?\]([^\[]*)');
    final out = <LyricLine>[];
    for (final m in re.allMatches(lrc)) {
      final mm = int.parse(m.group(1)!);
      final ss = int.parse(m.group(2)!);
      final xx = int.parse(m.group(3) ?? '0');
      final text = m.group(4)!.trim();
      out.add(
        LyricLine(
          Duration(minutes: mm, seconds: ss, milliseconds: xx),
          text,
        ),
      );
    }
    out.sort((a, b) => a.time.compareTo(b.time));
    return out.isEmpty ? [LyricLine(Duration.zero, fallbackName)] : out;
  }

  // —— 歌单 ——
  @override
  Future<List<Playlist>> recommendPlaylists() async {
    final r = await _get(KugouEndpoints.playlistDetail, query: {});
    // 推荐歌单走 /top/playlist（分类歌单），字段与 playlistDetail 不同，这里用
    // /playlist/detail 兜底拿热歌榜歌单。真机联调时如需分类歌单再切 topPlaylist。
    final data = r?['data'] ?? r;
    final list = _listOf(data);
    return list
        .whereType<Map<String, dynamic>>()
        .map(_playlistFromJson)
        .where((p) => p.id.isNotEmpty)
        .toList();
  }

  Playlist _playlistFromJson(Map<String, dynamic> j) {
    String str(dynamic v) => v?.toString() ?? '';
    final id = str(j['specialid'] ?? j['id'] ?? j['global_collection_id']);
    final name = str(j['specialname'] ?? j['name'] ?? j['title']);
    final cover = str(j['sizable_cover'] ?? j['imgurl'] ?? j['img'] ?? j['pic'] ?? j['cover']);
    final count = int.tryParse(str(j['songcount'] ?? j['song_count'] ?? j['count'])) ?? 0;
    final desc = str(j['intro'] ?? j['description'] ?? j['desc']);
    return Playlist(
      id: id,
      name: name.isEmpty ? '未命名歌单' : name,
      desc: desc,
      coverUrl: cover.isEmpty ? null : cover,
      playCount: count,
      coverColor: gradientColor(id.hashCode.abs()),
    );
  }

  @override
  Future<List<Song>> playlistTracks(Playlist playlist) async {
    final r = await _get(
      KugouEndpoints.playlistTrackAll,
      query: {
        'global_collection_id': playlist.id,
        'page': 1,
        'pagesize': 30,
      },
    );
    return _songsFrom(r);
  }

  // —— 榜单 ——
  @override
  Future<List<RankCategory>> rankCategories() async {
    final r = await _get(KugouEndpoints.rankList, query: {'withsong': 1});
    final data = r?['data'] ?? r;
    // /rank/list 结构：data.rank（官方榜） + data.customize（自定义榜）。
    final out = <RankCategory>[];
    if (data is Map<String, dynamic>) {
      for (final key in const ['rank', 'customize', 'special']) {
        final arr = data[key];
        if (arr is List) {
          for (final e in arr) {
            if (e is Map) {
              final name = (e['rankname'] ?? e['name'] ?? e['specialname'] ?? '').toString();
              final desc = (e['intro'] ?? e['desc'] ?? '').toString();
              if (name.isNotEmpty) out.add(RankCategory(name: name, desc: desc));
            }
          }
        }
      }
    }
    return out;
  }

  @override
  Future<List<Song>> rankSongs(RankCategory category) async {
    // category 只带 name/desc，没有 rankid。这里需要从 /rank/list 反查 rankid。
    final r = await _get(KugouEndpoints.rankList, query: {'withsong': 1});
    final data = r?['data'] ?? r;
    String? rankId;
    if (data is Map<String, dynamic>) {
      for (final key in const ['rank', 'customize', 'special']) {
        final arr = data[key];
        if (arr is List) {
          for (final e in arr) {
            if (e is Map &&
                (e['rankname'] == category.name || e['name'] == category.name)) {
              rankId = (e['rankid'] ?? e['id'] ?? e['specialid'])?.toString();
              break;
            }
          }
        }
        if (rankId != null) break;
      }
    }
    if (rankId == null) return const [];

    final songs = await _get(
      KugouEndpoints.rankAudio,
      query: {'rankid': rankId, 'page': 1, 'pagesize': 30},
    );
    return _songsFrom(songs);
  }

  // —— 每日推荐 ——
  @override
  Future<List<Song>> dailyRecommend() async {
    final r = await _get(KugouEndpoints.everydayRecommend);
    return _songsFrom(r);
  }

  // —— 个人中心（收藏）——
  @override
  Future<List<Song>> favoriteSongs() async {
    // 收藏歌曲依赖「我喜欢」歌单，需要登录态。当前阶段未登录时返回空；
    // 真机联调时：getUserPlaylist → 找「我喜欢」→ playlistTrackAll。
    return const [];
  }

  // —— 私人 FM ——
  @override
  Future<Song> fmNext() async {
    final r = await _get(KugouEndpoints.personalFm);
    final songs = _songsFrom(r);
    if (songs.isNotEmpty) return songs.first;
    return const Song(name: '未知歌曲', artist: '未知歌手', album: '');
  }

  @override
  Future<List<Playlist>> fmScenes() async {
    final r = await _get(KugouEndpoints.sceneLists);
    final data = r?['data'] ?? r;
    final list = _listOf(data);
    return list
        .whereType<Map<String, dynamic>>()
        .map((j) {
          String str(dynamic v) => v?.toString() ?? '';
          final name = str(j['scene_name'] ?? j['name'] ?? j['title']);
          final desc = str(j['intro'] ?? j['desc'] ?? j['sub_title']);
          return Playlist(
            id: str(j['id'] ?? j['scene_id']),
            name: name.isEmpty ? '场景' : name,
            desc: desc,
            coverUrl: str(j['imgurl'] ?? j['img'] ?? j['pic']).isEmpty
                ? null
                : str(j['imgurl'] ?? j['img'] ?? j['pic']),
            playCount: 0,
            coverColor: gradientColor(name.hashCode.abs()),
          );
        })
        .toList();
  }

  // —— 专辑 ——
  @override
  Future<List<Song>> albumTracks(Album album) async {
    final r = await _get(
      KugouEndpoints.albumSongs,
      query: {'id': album.id, 'page': 1, 'pagesize': 30},
    );
    return _songsFrom(r);
  }

  // —— 歌手 ——
  @override
  Future<List<Song>> artistSongs(Artist artist) async {
    final r = await _get(
      KugouEndpoints.artistAudios,
      query: {'id': artist.id, 'page': 1, 'pagesize': 30},
    );
    return _songsFrom(r);
  }

  @override
  Future<List<Album>> artistAlbums(Artist artist) async {
    final r = await _get(
      KugouEndpoints.artistAlbums,
      query: {'singerid': artist.id, 'page': 1, 'pagesize': 30},
    );
    final data = r?['data'] ?? r;
    final list = _listOf(data);
    return list
        .whereType<Map<String, dynamic>>()
        .map((j) {
          String str(dynamic v) => v?.toString() ?? '';
          final name = str(j['album_name'] ?? j['albumname'] ?? j['name']);
          final cover = str(j['sizable_cover'] ?? j['imgurl'] ?? j['img'] ?? j['pic']);
          return Album(
            id: str(j['album_id'] ?? j['albumid'] ?? j['id']),
            name: name.isEmpty ? '未命名专辑' : name,
            artist: str(j['singer_name'] ?? j['singername'] ?? artist.name),
            coverUrl: cover.isEmpty ? null : cover,
            publishTime: str(j['publish_time'] ?? j['date'] ?? j['year']),
            trackCount: int.tryParse(str(j['songcount'] ?? j['song_count'] ?? j['count'])) ?? 0,
            coverColor: gradientColor(name.hashCode.abs()),
          );
        })
        .toList();
  }

  // —— 基础设施 ——
  @override
  Future<void> registerDev() async {
    await _get(KugouEndpoints.registerDev);
  }

  @override
  Future<String?> getModel() async {
    final r = await _get(KugouEndpoints.getModel);
    final data = r?['data'] ?? r;
    if (data is Map<String, dynamic>) {
      return (data['model'] ?? data['name'] ?? data['device']).toString();
    }
    return null;
  }
}
