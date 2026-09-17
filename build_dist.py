#!/usr/bin/env python3
"""构建上架 WorkBuddy 开放平台用的技能 ZIP 包。

输出：wecom-chat-export.zip（顶层目录 wecom-chat-export/）
结构遵循官方规范：
  wecom-chat-export/
    SKILL.md          # 必须
    references/       # 可选：参考资料
    scripts/          # 可选：可执行脚本
    assets/icon.png   # 图标（表单单独上传，包内仅留小图标）
自动排除：密钥 / 解密产物 / .git / 缓存 / 1.9MB 横幅图 / 发布脚本。
包体积需 <= 3MB。
"""
import os
import sys
import zipfile

ROOT = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(ROOT, "wecom-chat-export.zip")
SKILL = "wecom-chat-export"

EXCLUDE_DIRS = {".git", "__pycache__", "wxwork_decrypted", "wxwork_export"}
EXCLUDE_FILES = {
    "config.json",          # 可能含本机密钥/路径，绝不打包
    "wxwork_keys.json",     # 提取出的密钥，绝不打包
    "publish.sh",
    ".gitignore",
    "wecom-chat-export.zip",
    "build_dist.py",
}
EXCLUDE_EXT = {".pyc"}


def wanted(rel: str) -> bool:
    parts = rel.split(os.sep)
    base = parts[-1]
    if base in EXCLUDE_FILES:
        return False
    if any(p in EXCLUDE_DIRS for p in parts):
        return False
    if base == "hero.png":  # 保留 icon.png，丢弃 1.9MB 横幅大图
        return False
    if os.path.splitext(base)[1] in EXCLUDE_EXT:
        return False
    return True


def main() -> None:
    if os.path.exists(OUT):
        os.remove(OUT)
    uncompressed = 0
    with zipfile.ZipFile(OUT, "w", zipfile.ZIP_DEFLATED) as z:
        for dirpath, dirnames, filenames in os.walk(ROOT):
            dirnames[:] = [d for d in dirnames if d not in EXCLUDE_DIRS]
            for fn in filenames:
                full = os.path.join(dirpath, fn)
                rel = os.path.relpath(full, ROOT)
                if not wanted(rel):
                    continue
                arc = os.path.join(SKILL, rel).replace(os.sep, "/")
                z.write(full, arc)
                uncompressed += os.path.getsize(full)
    size = os.path.getsize(OUT)
    print(f"Built {OUT}")
    print(f"  uncompressed ~{uncompressed/1024:.0f} KB, zip = {size/1024:.0f} KB")
    if size > 3 * 1024 * 1024:
        print("  WARNING: 超过 3MB 限制！", file=sys.stderr)
    with zipfile.ZipFile(OUT) as z:
        print(f"  entries: {len(z.namelist())}")


if __name__ == "__main__":
    main()
