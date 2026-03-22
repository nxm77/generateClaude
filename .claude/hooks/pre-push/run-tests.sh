#!/bin/bash

# CX Claude Code - Pre-push Hook
# 功能: 推送前运行测试

echo "=== Pre-push 检查 ==="

# 检查是否有测试
if [ -f "pom.xml" ]; then
    echo "检测到 Maven 项目，运行测试..."
    mvn test
    if [ $? -ne 0 ]; then
        echo "❌ Maven 测试失败"
        exit 1
    fi
elif [ -f "package.json" ]; then
    echo "检测到 Node.js 项目，运行测试..."
    npm test
    if [ $? -ne 0 ]; then
        echo "❌ npm 测试失败"
        exit 1
    fi
elif [ -f "Makefile" ]; then
    echo "检测到 Makefile，运行 make test..."
    make test
    if [ $? -ne 0 ]; then
        echo "❌ make test 失败"
        exit 1
    fi
elif [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
    echo "检测到 Gradle 项目，运行测试..."
    ./gradlew test
    if [ $? -ne 0 ]; then
        echo "❌ Gradle 测试失败"
        exit 1
    fi
else
    echo "⚠️  未检测到测试配置，跳过测试"
fi

echo "✅ Pre-push 检查通过"
exit 0
