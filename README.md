# wecom-chat-export

WorkBuddy 技能：解密并导出**本机企业微信（WeCom / WXWork）**本地聊天记录，用于分析与总结。

> 适用：Windows 上的企业微信 5.x（WXWork.exe，32 位）。与个人微信（Weixin.exe / SQLCipher）**不是**同一套体系，请勿混用。

## 它能做什么
1. 从 `WXWork.exe` 进程内存读取全局主密钥（**无需管理员权限**，读的是你自己的进程）。
2. 解密 `wxSQLite3 AES-128-CBC` 加密的 `message.db` / `user.db` / `session.db` 等（企业微信所有库共用一把 16 字节密钥）。
3. 把会话导出为 JSON / HTML / CSV，并列出全部会话，便于进一步分析。

## 安装方法
把本仓库里的 `wecom-chat-export/` 文件夹放到 WorkBuddy 的技能目录之一：

- **用户级（所有项目可用）**：`~/.workbuddy/skills/wecom-chat-export/`
- **项目级（团队共享）**：`<项目>/.workbuddy/skills/wecom-chat-export/`

Git 克隆示例（Windows PowerShell）：
```powershell
git clone <本仓库URL> $env:TEMP\wce
Copy-Item -Recurse $env:TEMP\wce\wecom-chat-export "$env:USERPROFILE\.workbuddy\skills\"
```

## 使用前准备（一次性）
- Python 3.13 虚拟环境，安装 `pycryptodome`：
  ```powershell
  python -m venv venv && .\venv\Scripts\pip install "pycryptodome>=3.19,<4"
  ```
- 从 `kenchikuliu/wechat-local-backup-search` 拉取脚本：
  `wxwork_crypto.py` `find_wxwork_keys.py` `key_scan_common.py` `key_utils.py`
  `decrypt_wxwork_db.py` `export_wxwork_messages.py` `config.py`
  （用 `https://gh-proxy.com/https://raw.githubusercontent.com/kenchikuliu/wechat-local-backup-search/main/<file>`）。
- 写 `config.json`，**显式**填 `wxwork_db_dir` 指向 `...\WXWork\<账号>\Data`（本机"文档"被华为电脑管家迁到 D 盘，自动探测会失败）。
- 企业微信客户端需保持登录且运行。

## 使用
```powershell
python find_wxwork_keys.py        # 提取密钥 -> wxwork_keys.json
python decrypt_wxwork_db.py       # 解密 -> wxwork_decrypted/
python export_wxwork_messages.py --list                 # 列出会话
python export_wxwork_messages.py --formats json,html,csv # 导出全部
```

## 免责声明
仅供导出**本人已同步**的聊天记录做个人分析。涉及个股/投资的群聊内容均为群友个人观点，不构成任何投资建议。
