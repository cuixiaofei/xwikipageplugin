#=====================================#
# 轻量级开源项目 Makefile
# 支持手动版本管理 + 简单CI/CD流程
#=====================================#
SHELL := /bin/bash

#----------- 项目配置 ------------#
PROJECT_NAME := mydotfiles
VERSION_FILE := VERSION
CURRENT_DATE := $(shell date +%Y-%m-%d)

#----------- Git配置 ------------#
BRANCH := main
REMOTE := origin

#----------- 版本管理 ------------#
# 读取当前版本
VERSION := $(shell cat $(VERSION_FILE) 2>/dev/null || echo "0.1.0")
MAJOR := $(shell echo $(VERSION) | cut -d. -f1)
MINOR := $(shell echo $(VERSION) | cut -d. -f2)
PATCH := $(shell echo $(VERSION) | cut -d. -f3)

#=====================================#
# 主要工作流程
#=====================================#
help:  ## 显示帮助信息
	@echo "=== $(PROJECT_NAME) - 版本 $(VERSION) ==="
	@echo "常用命令:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo "\n版本管理:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {if($$1 ~ /^version/) printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

#=====================================#
# 日常开发流程
#=====================================#
status:  ## 查看项目状态
	@echo "=== 项目状态 ==="
	@echo "📁 项目: $(PROJECT_NAME)"
	@echo "🏷️  版本: $(VERSION)"
	@echo "📅 日期: $(CURRENT_DATE)"
	@echo ""
	@echo "=== Git 状态 ==="
	@git status -s
	@echo ""
	@echo "=== 分支信息 ==="
	@git branch -vv | grep "^*" || echo "当前无分支"

add:  ## 添加所有变更到暂存区
	@echo "📦 添加变更到暂存区..."
	git add .
	@echo "✅ 已添加所有变更"

commit:  ## 交互式提交 (示例: make commit MSG="修复登录bug")
	@if [ -z "$(MSG)" ]; then \
		echo "❌ 错误: 请提供提交信息"; \
		echo "💡 示例: make commit MSG=\"修复内存泄漏问题\""; \
		exit 1; \
	fi
	git commit -m "$(MSG)"
	@echo "✅ 提交成功: $(MSG)"

quick-commit:  ## 快速提交，使用默认消息
	@echo "⚡ 快速提交中..."
	git add .
	git commit -m "更新: $(CURRENT_DATE) 的修改"
	@echo "✅ 快速提交完成"

push:  ## 推送到远程仓库
	@echo "🚀 推送到 $(REMOTE)/$(BRANCH)..."
	git push $(REMOTE) $(BRANCH)
	@echo "✅ 推送完成"

pull:  ## 从远程仓库拉取更新
	@echo "📥 拉取远程更新..."
	git pull $(REMOTE) $(BRANCH)
	@echo "✅ 拉取完成"

sync:  ## 完整的同步流程 (pull → add → commit → push)
	@echo "🔄 开始同步流程..."
	make pull
	make add
	make quick-commit
	make push
	@echo "✅ 同步完成"

#=====================================#
# 语义化版本管理
#=====================================#
version-show:  ## 显示当前版本
	@echo "当前版本: $(VERSION)"

version-patch:  ## 递增修订版本 (1.0.0 → 1.0.1)
	@$(eval NEW_PATCH := $(shell echo $$(($(PATCH) + 1))))
	@$(eval NEW_VERSION := $(MAJOR).$(MINOR).$(NEW_PATCH))
	@echo $(NEW_VERSION) > $(VERSION_FILE)
	@echo "✅ 版本已更新: $(VERSION) → $(NEW_VERSION)"

version-minor:  ## 递增次版本 (1.0.1 → 1.1.0)
	@$(eval NEW_MINOR := $(shell echo $$(($(MINOR) + 1))))
	@$(eval NEW_VERSION := $(MAJOR).$(NEW_MINOR).0)
	@echo $(NEW_VERSION) > $(VERSION_FILE)
	@echo "✅ 版本已更新: $(VERSION) → $(NEW_VERSION)"

version-major:  ## 递增主版本 (1.1.0 → 2.0.0)
	@$(eval NEW_MAJOR := $(shell echo $$(($(MAJOR) + 1))))
	@$(eval NEW_VERSION := $(NEW_MAJOR).0.0)
	@echo $(NEW_VERSION) > $(VERSION_FILE)
	@echo "✅ 版本已更新: $(VERSION) → $(NEW_VERSION)"

#=====================================#
# 手动测试与质量检查
#=====================================#
test:  ## 运行本地测试 (手动)
	@echo "🧪 运行本地测试..."
	@echo "请根据你的项目类型添加测试命令:"
	@echo "  Python: python -m pytest tests/ || python test.py"
	@echo "  Node.js: npm test || node test.js"
	@echo "  Shell: bash test.sh"
	@echo ""
	@echo "✅ 测试完成 (请手动验证结果)"

lint:  ## 代码风格检查 (手动)
	@echo "🔍 代码风格检查..."
	@echo "请根据你的项目类型添加检查命令:"
	@echo "  Python: flake8 . || pylint ."
	@echo "  Node.js: eslint . || prettier --check ."
	@echo "  Shell: shellcheck *.sh"
	@echo ""
	@echo "✅ 检查完成 (请手动修复问题)"

check: test lint  ## 完整的质量检查 (手动)

#=====================================#
# 发布流程
#=====================================#
release-patch: version-patch  ## 发布修订版本 (补丁)
	@echo "📦 发布补丁版本..."
	git add $(VERSION_FILE)
	git commit -m "发布: 版本 $(shell cat $(VERSION_FILE)) (补丁更新)"
	@if git rev-parse -q --verify "v$(shell cat $(VERSION_FILE))" >/dev/null; then \
		echo "⚠️  标签 v$(shell cat $(VERSION_FILE)) 已存在，先删除..."; \
		git tag -d "v$(shell cat $(VERSION_FILE))" 2>/dev/null || true; \
		git push origin --delete "v$(shell cat $(VERSION_FILE))" 2>/dev/null || true; \
	fi
	git tag -a "v$(shell cat $(VERSION_FILE))" -m "发布版本 $(shell cat $(VERSION_FILE))"
	@echo "✅ 补丁发布完成，请执行: make push"

release-minor: version-minor  ## 发布次版本 (新功能)
	@echo "📦 发布次版本..."
	git add $(VERSION_FILE)
	git commit -m "发布: 版本 $(shell cat $(VERSION_FILE)) (新功能)"
	@if git rev-parse -q --verify "v$(shell cat $(VERSION_FILE))" >/dev/null; then \
		echo "⚠️  标签 v$(shell cat $(VERSION_FILE)) 已存在，先删除..."; \
		git tag -d "v$(shell cat $(VERSION_FILE))" 2>/dev/null || true; \
		git push origin --delete "v$(shell cat $(VERSION_FILE))" 2>/dev/null || true; \
	fi
	git tag -a "v$(shell cat $(VERSION_FILE))" -m "发布版本 $(shell cat $(VERSION_FILE))"
	@echo "✅ 次版本发布完成，请执行: make push"

release-major: version-major  ## 发布主版本 (重大更新)
	@echo "📦 发布主版本..."
	git add $(VERSION_FILE)
	git commit -m "发布: 版本 $(shell cat $(VERSION_FILE)) (重大更新)"
	@if git rev-parse -q --verify "v$(shell cat $(VERSION_FILE))" >/dev/null; then \
		echo "⚠️  标签 v$(shell cat $(VERSION_FILE)) 已存在，先删除..."; \
		git tag -d "v$(shell cat $(VERSION_FILE))" 2>/dev/null || true; \
		git push origin --delete "v$(shell cat $(VERSION_FILE))" 2>/dev/null || true; \
	fi
	git tag -a "v$(shell cat $(VERSION_FILE))" -m "发布版本 $(shell cat $(VERSION_FILE))"
	@echo "✅ 主版本发布完成，请执行: make push"

#=====================================#
# Git 实用工具
#=====================================#
log:  ## 查看提交历史 (最近10条)
	@echo "📜 最近提交历史:"
	git log --oneline -10
	@echo ""
	@echo "📊 统计信息:"
	@git log --pretty=format:'%h - %an, %ar : %s' | head -5

branch:  ## 查看分支信息
	@echo "🌿 分支信息:"
	git branch -a
	@echo ""
	@echo "📍 当前分支:"
	git branch --show-current

remote:  ## 查看远程仓库信息
	@echo "🌐 远程仓库信息:"
	git remote -v

clean:  ## 清理未跟踪文件 (谨慎使用)
	@echo "🧹 清理未跟踪文件..."
	git clean -fd
	@echo "✅ 清理完成"

#=====================================#
# 项目初始化
#=====================================#
## 检查开源基础结构是否齐全（零覆盖）
init-check:
	@echo "🔍 检查基础结构..."; \
	miss=; \
	for f in README.md CONTRIBUTING.md CHANGELOG.md .gitignore VERSION; do \
		[ -e "$$f" ] && echo "✅ $$f" || miss="$$miss $$f"; \
	done; \
	[ -z "$$miss" ] && echo "🎉 齐备" || (echo "❌ 缺失:$${miss}"; exit 1)

## 初始化 Git 仓库（默认 main + 首次提交）
init:
	@if [ -d .git ]; then \
		echo "✅ Git 仓库已存在"; \
	else \
		echo "🔰 正在初始化 Git 仓库..."; \
		git init --quiet && \
		git checkout -b main 2>/dev/null || true && \
		echo "📂 仓库路径: $$(pwd)" && \
		echo "🌿 默认分支: main" && \
		echo "🔑 远程地址: 未配置（稍后 git remote add）"; \
		if [ ! -f .gitignore ]; then \
			echo "node_modules/\ndist/\nbuild/\n*.log\n.env" > .gitignore; \
			echo "✅ 已创建默认 .gitignore"; \
		fi; \
		if [ -z "$$(git log --oneline -1 2>/dev/null)" ]; then \
			git add . && \
			git commit --quiet -m "first commit" && \
			echo "🎉 首次提交已准备"; \
		fi; \
	fi

.PHONY: help status add commit quick-commit push pull sync version-show version-patch version-minor version-major test lint check release-patch release-minor release-major log branch remote clean init init-check