# 酷狗 API 接口清单（源自 md3Music / KuGouMusicApi）

> 来源：`kugou_api_server/rust/src/modules/mod.rs` 的 `register()` 路由表，共 **165 个接口**。
> 调用方式：内嵌 Rust 服务在 `127.0.0.1:{随机端口}` 起 HTTP 服务，App 通过 `GET/POST http://127.0.0.1:{port}{路径}` 调用，返回统一 JSON。
> 登录态通过 `cookie` 里的 `token` / `userid` / `dfid` / `mid` 传递（登录接口返回后自动注入）。

标 ⭐ 为「车机音乐播放器」大概率需要的核心域，供你优先勾选。

---

## 1. ⭐ 登录 / 鉴权（11）
| 接口 | 说明 |
|---|---|
| `/login/cellphone` | 手机号 + 验证码登录 |
| `/login` | 账号密码登录 |
| `/login/token` | 用 token 免密登录 / 刷新登录态 |
| `/login/qr/create` `/login/qr/check` `/login/qr/key` | 二维码扫码登录（创建/轮询/key） |
| `/login/wx/create` `/login/wx/check` | 微信登录 |
| `/login/openplat` | 开放平台（QQ 等）登录 |
| `/login/device` `/login/device/kick` | 登录设备列表 / 踢下线 |
| `/captcha/sent` | 发送验证码 |

## 2. ⭐ 搜索（13）
| 接口 | 说明 |
|---|---|
| `/search` | 综合搜索（歌曲） |
| `/search/mixed` | 混合搜索（歌曲+歌手+专辑） |
| `/search/suggest` | 搜索联想词 |
| `/search/hot` | 热搜榜 |
| `/search/default` | 默认搜索词 |
| `/search/album` `/search/artist` `/search/special` `/search/lyric` | 专辑/歌手/歌单/歌词搜索 |
| `/search/complex` | 复合搜索 |
| `/search/audiobook` | 有声书搜索 |

## 3. ⭐ 歌曲播放（6）
| 接口 | 说明 |
|---|---|
| `/song/url` | 获取歌曲播放直链（核心） |
| `/song/url/new` | 新版播放地址接口 |
| `/song/climax` | 歌曲高潮片段 |
| `/privilege/lite` | 试听/权限判断（是否 VIP） |
| `/audio` | 音频信息 |
| `/audio/related` | 相关音频 |

## 4. ⭐ 歌词（1）
| 接口 | 说明 |
|---|---|
| `/lyric` | 歌词（含逐字 KRC 解析） |

## 5. ⭐ 歌单（11）
| 接口 | 说明 |
|---|---|
| `/playlist/detail` | 歌单详情 |
| `/playlist/track/all` `/playlist/track/all/new` | 歌单全部歌曲 |
| `/playlist/tags` | 歌单分类标签 |
| `/playlist/similar` | 相似歌单 |
| `/playlist/add` `/playlist/del` | 新建 / 删除歌单 |
| `/playlist/tracks/add` `/playlist/tracks/del` | 歌单加歌 / 删歌 |
| `/playlist/effect` | 歌单编辑 |
| `/import/playlist` | 导入歌单 |

## 6. ⭐ 排行榜 / 榜单（11）
| 接口 | 说明 |
|---|---|
| `/rank/list` | 榜单分类列表 |
| `/rank/top` | 榜单 TOP 内容 |
| `/rank/info` `/rank/vol` `/rank/audio` | 榜单详情/期号/音频 |
| `/top/song` `/top/album` `/top/playlist` | 各类 TOP 榜 |
| `/top/card` `/top/ip` `/top/card/youth` | TOP 卡片 / IP / 青年榜 |
| `/sheet/rank` | 曲谱榜单 |

## 7. ⭐ 每日推荐 / 推荐（6）
| 接口 | 说明 |
|---|---|
| `/everyday/recommend` | 每日推荐 |
| `/everyday/style/recommend` | 风格推荐 |
| `/recommend/songs` | 推荐歌曲 |
| `/ai/recommend` | AI 推荐 |
| `/everyday/history` `/everyday/friend` | 推荐历史 / 好友推荐 |

## 8. ⭐ 用户 / 个人中心（17）
| 接口 | 说明 |
|---|---|
| `/user/detail` | 用户资料 |
| `/user/playlist` | 我的歌单 |
| `/user/history` | 听歌历史 |
| `/user/listen` `/user/listen/report` | 听歌记录 / 报告 |
| `/user/grade/info` | 听歌等级 |
| `/user/vip/detail` | VIP 状态 |
| `/user/follow` `/user/follow/message` | 关注 / 关注消息 |
| `/user/video/collect` `/user/video/love` | 视频收藏/喜欢 |
| `/user/purchased/songs` `/user/purchased/albums` | 已购歌曲/专辑 |
| `/user/cloud` `/user/cloud/url` `/user/cloud/upload` `/user/cloud/del` | 云盘（列表/取链/上传/删除） |

## 9. ⭐ 私人 FM / 电台（6）
| 接口 | 说明 |
|---|---|
| `/personal/fm` | 私人 FM |
| `/fm/class` `/fm/image` `/fm/recommend` `/fm/songs` | FM 分类/图/推荐/歌曲 |
| `/pc/diantai` | 电脑电台 |

## 10. ⭐ 专辑（5）
| 接口 | 说明 |
|---|---|
| `/album` `/album/detail` | 专辑详情 |
| `/album/songs` | 专辑歌曲 |
| `/album/shop` | 数字专辑购买 |
| `/album/dycover` | 动态封面（视频封面） |

## 11. ⭐ 歌手（9）
| 接口 | 说明 |
|---|---|
| `/artist/detail` | 歌手详情 |
| `/artist/audios` `/artist/albums` `/artist/videos` | 歌手歌曲/专辑/视频 |
| `/artist/lists` | 歌手相关列表 |
| `/artist/follow` `/artist/unfollow` | 关注/取关 |
| `/artist/follow/newsongs` `/artist/honour` | 新歌 / 荣誉 |

## 12. ⭐ 评论（12）
| 接口 | 说明 |
|---|---|
| `/comment/music` `/comment/album` `/comment/playlist` `/comment/floor` | 各类型评论列表 |
| `/comment/count` | 评论数 |
| `/comment/music/send` `/comment/album/send` `/comment/playlist/send` `/comment/floor/send` | 发表评论 |
| `/comment/music/hotword` `/comment/music/classify` `/comment/music/topliked` | 热词/分类/最赞 |

## 13. 视频 / MV（5）
| 接口 | 说明 |
|---|---|
| `/video/detail` `/video/url` `/video/privilege` | 视频详情/地址/权限 |
| `/video/barrage` `/video/barrage/send` | 弹幕列表 / 发弹幕 |

## 14. 听书 / 长音频（8）
| 接口 | 说明 |
|---|---|
| `/longaudio/daily/recommend` `/longaudio/week/recommend` `/longaudio/vip/recommend` `/longaudio/rank/recommend` | 各类推荐 |
| `/longaudio/album/list` `/longaudio/album/detail` `/longaudio/album/audios` | 专辑列表/详情/音频 |
| `/longaudio/tag/list` | 分类标签 |

## 15. 场景音乐（8）
| 接口 | 说明 |
|---|---|
| `/scene/music` `/scene/module` `/scene/module/info` | 场景音乐/模块 |
| `/scene/lists` `/scene/lists/v2` | 场景列表 |
| `/scene/audio/list` `/scene/collection/list` `/scene/video/list` | 场景音频/合辑/视频 |

## 16. 乐库 / 精选（3）
| 接口 | 说明 |
|---|---|
| `/yueku` | 乐库首页 |
| `/yueku/banner` | 乐库 Banner |
| `/yueku/fm` | 乐库 FM |

## 17. IP 编辑精选（5）
| 接口 | 说明 |
|---|---|
| `/ip` `/ip/playlist` `/ip/zone` `/ip/zone/home` `/ip/dateil` | IP 专区内容 |

## 18. 主题（4）
| 接口 | 说明 |
|---|---|
| `/theme/music` `/theme/music/detail` `/theme/playlist` `/theme/playlist/track` | 主题音乐/歌单 |

## 19. 曲谱（6）
| 接口 | 说明 |
|---|---|
| `/sheet/song` `/sheet/detail` `/sheet/explore` `/sheet/rank` `/sheet/tags` `/sheet/collection` | 曲谱相关 |

## 20. 听歌识曲（2）
| 接口 | 说明 |
|---|---|
| `/audio/match` | 哼唱/录音识别 |
| `/extras/pcm-process` | PCM 音频预处理 |

## 21. 一起听（5）
| 接口 | 说明 |
|---|---|
| `/listen/together/room` `/music` `/study` `/chat` `/discovery` | 一起听房间/点歌/自习/聊天/发现 |

## 22. 青年版 / 潮流（16）
| 接口 | 说明 |
|---|---|
| `/youth/channel/*` `/youth/day/vip*` `/youth/dynamic*` `/youth/listen/song` `/youth/month/vip*` `/youth/union/vip` `/youth/user/song` `/youth/vip` | 青年版频道/VIP/动态等 |

## 23. 音效 / 品牌（4）
| 接口 | 说明 |
|---|---|
| `/effects/brand` `/effects/brand/detail` `/effects/match` `/effects/artist` | 音效品牌/匹配/歌手 |

## 24. 其他 / 杂项（12）
| 接口 | 说明 |
|---|---|
| `/register/dev` | 设备注册（换取 dfid，风控必需） |
| `/get/model` | 获取机型 |
| `/server/now` | 服务器时间 |
| `/images` `/images/audio` | 图片资源 |
| `/favorite/count` | 收藏数 |
| `/lastest/songs/listen` | 最近在听 |
| `/singer/list` | 歌手列表 |
| `/song/ranking` `/song/ranking/filter` | 歌曲热度排行 |
| `/songlist/add` | 添加到列表 |
| `/playhistory/upload` | 播放历史上报 |
| `/brush` | 刷刷短视频流 |
| `/get/verify/info` `/verify/user/info` | 验证信息 |

---

## 说明

- **必选但"隐形"**：`/register/dev`（设备注册）、`/get/model` —— 没它们风控过不去、其他接口会报错，属于基础设施。
- **播放链路三件套**：`/song/url`（拿播放地址）→ `/lyric`（歌词）→ `/song/climax`（可选高潮）。
- 接口的入参/返回值细节在 `modules/*.rs` 里，等你选定功能后我按你的需要逐个补「参数 + 返回」对接文档。
