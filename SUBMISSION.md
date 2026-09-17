# 提交到 WorkBuddy 官方技能市场（SkillHub）指南

本文件说明如何把 `wecom-chat-export` 上架到 WorkBuddy 官方技能市场，并附上表单所需的预填信息。

## 一、官方入口与流程

1. **开放平台入驻**
   打开 **WorkBuddy 开放平台** 👉 https://open.workbuddy.cn/
   - 首次使用先完成「入驻 / 认证 / 开发者信息审核」（邮箱验证即可）。
   - 官方文档：入驻指南 https://open.workbuddy.cn/docs/onboarding ｜ 技能结构 https://open.workbuddy.cn/docs/skill ｜ 技能市场使用 https://www.workbuddy.cn/docs/workbuddy/From-Beginner-to-Expert-Guide/Function-Description/Skills-Market
   - 支持邮箱：openworkbuddy@tencent.com（解析失败或审核疑问）

2. **创建技能**
   - 进入「发布管理 → 技能」，点右上角「创建」。
   - 上传本仓库构建好的 **`wecom-chat-export.zip`**（已生成，顶层目录为 `wecom-chat-export/SKILL.md`，符合官方结构）。
   - 平台自动解压、识别内容并生成「技能 ID」。

3. **完善展示信息**（右侧可预览）
   - **市场展示名称**：见下方预填。
   - **市场展示分类**：按实际用途选（建议「效率办公」相关类目）。
   - **服务类目**：至少 1 个、至多 5 个（建议「工具-办公」）。
   - **图标**：上传 `assets/icon.png`（512×512 PNG，≤500KB，已生成）。
   - 注意：部分字段由包内 `SKILL.md` frontmatter 解析得到，**页面上不可直接改**；若写错需回到 `SKILL.md` 修改后重新打包上传。

4. **提交审核**
   - 核对汇总信息无误后点「提交」。
   - 审核维度：安全性（有无恶意代码）、稳定性（是否崩溃）、合规性（是否违规）。
   - 时长参考：约 1–3 个工作日（实测有 18 小时通过的案例）。

5. **发布**
   - 审核通过后，回「发布管理 → 技能」，状态变「待发布」，点「发布」。
   - 发布方式选 **「公开发布」**（全部用户可见，出现在 WorkBuddy 技能市场可被搜索安装）；「专用发布」仅限你自己账号下的 Buddy 应用。
   - 发布后，在 WorkBuddy 客户端「专家·技能·连接器 → 技能」里搜索名称即可安装。

## 二、表单预填信息（可直接复制）

| 字段 | 值 |
|---|---|
| 技能名称（name） | `wecom-chat-export` |
| 展示名称（display_name） | 企业微信聊天记录导出与解密 |
| 英文名（display_name_en） | WeCom Chat Export & Decryption |
| 描述（description，含触发词） | 本技能用于读取、解密、导出并分析用户自己电脑上企业微信（WeCom/WXWork）的本地聊天数据库。覆盖定位数据目录、从 WXWork.exe 进程内存提取全局主密钥（无需管理员）、解密 wxSQLite3 AES-128-CBC 数据库、并导出为 JSON/HTML/CSV 供分析。触发词示例："导出企业微信聊天记录"、"企业微信数据库解密"、"读取 WXWork 记录"、"分析企业微信聊天"。 |
| 中文简介（description_zh） | 读取并解密你自己电脑上的企业微信（WeCom/WXWork）本地聊天数据库，导出为 JSON/HTML/CSV 供分析；全程仅访问本机数据，不上传云端。 |
| 英文简介（description_en） | Decrypt and export your own local WeCom (WXWork) chat databases on Windows, then analyze them as JSON/HTML/CSV. Runs fully offline on your PC. |
| 分类（category） | `productivity`（可改为 `dev` / `data`） |
| 版本（version） | `1.0.0` |
| 作者（author） | `woliejia`（请改成你自己的发布者名） |

> 以上字段已写入 `SKILL.md` 的 frontmatter，平台会从包内读取；如需改动，编辑 `SKILL.md` 后重跑 `python build_dist.py` 重新生成 ZIP 再上传。

## 三、权限与合规声明（建议写进技能介绍或提交备注）

- **仅访问本机数据**：只读取用户自己电脑上企业微信的本地加密数据库与 `WXWork.exe` 进程内存，不连接任何外部服务器，不上传任何内容到云端。
- **无需管理员权限**：密钥提取通过 `OpenProcess` 读取**用户自己的**进程内存完成，普通权限即可。
- **密钥不出本机**：主密钥每次会话从内存重新提取，不持久化保存；`scripts/config.json`、`wxwork_keys.json`、解密产物**均不打包**进提交 ZIP。
- **适用环境**：仅 Windows + 企业微信（WeCom/WXWork 5.x），与个人微信（SQLCipher 4）不兼容。
- **合规提示**：技能用于**用户导出并分析自己的聊天记录**；使用者需自行确保符合当地法律法规与企业微信使用规范。

## 四、包内容说明（wecom-chat-export.zip）

- 结构：`wecom-chat-export/{SKILL.md, README.md, LICENSE, NOTICE, references/, scripts/, assets/icon.png}`
- 已排除：`.git`、`__pycache__`、`*.pyc`、`config.json`、`wxwork_keys.json`、`publish.sh`、`.gitignore`、解密产物目录、1.9MB 横幅大图（仅保留小图标）。
- 体积：约 234 KB（< 3MB 限制）。
- 重新生成：`python build_dist.py`（在本仓库根目录运行）。

## 五、常见坑

- **解析失败**：绝大多数因为目录结构不对（SKILL.md 必须直接在技能目录下，不要多套一层）或 frontmatter 字段缺失。对照 https://open.workbuddy.cn/docs/skill 检查。
- **含密钥被拒**：务必确认 ZIP 内没有 `config.json` / `wxwork_keys.json` / 解密导出目录。
- **图标尺寸**：必须为 512×512、≤500KB 的 JPG/PNG；本仓库 `assets/icon.png` 已满足。
