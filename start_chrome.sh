#!/bin/bash

# 设置颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 版本检查函数
check_drivers() {
    # 获取Chrome完整版本号（例如：133.0.6943.53）
    CHROME_FULL_VERSION=$(/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --version | awk '{print $3}')
    CHROME_MAJOR_VERSION=$(echo "$CHROME_FULL_VERSION" | cut -d'.' -f1)  # 只取主版本号
    echo -e "${YELLOW}检测到Chrome版本: ${CHROME_FULL_VERSION}${NC}"

    # 检查chromedriver安装状态
    check_driver() {
        # 检查常见安装路径
        PATHS=("/opt/homebrew/bin/chromedriver" "/usr/local/bin/chromedriver")
        for path in "${PATHS[@]}"; do
            if [ -f "$path" ]; then
                DRIVER_PATH="$path"
                break
            fi
        done

        if [ -z "$DRIVER_PATH" ]; then
            echo -e "${RED}未找到chromedriver安装路径${NC}"
            return 1
        fi
        
        DRIVER_VERSION=$($DRIVER_PATH --version | awk '{print $2}')
        echo -e "${YELLOW}当前chromedriver版本: ${DRIVER_VERSION}${NC}"
        
        if [[ ! "$DRIVER_VERSION" == "$CHROME_MAJOR_VERSION"* ]]; then
            echo -e "${RED}版本不兼容！${NC}"
            return 1
        fi
        return 0
    }

    # 自动安装驱动
    install_driver() {
        echo -e "${YELLOW}正在使用Homebrew安装chromedriver...${NC}"
        brew install --cask chromedriver
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}安装成功！${NC}"
            return 0
        else
            echo -e "${RED}安装失败！${NC}"
            return 1
        fi
    }

    # 执行版本检查
    if ! check_driver; then
        echo -e "${YELLOW}正在尝试自动更新驱动...${NC}"
        if install_driver; then
            echo -e "${GREEN}版本兼容性问题已解决！${NC}"
        else
            echo -e "${RED}自动更新失败！${NC}"
            return 1
        fi
    else
        echo -e "${GREEN}版本兼容性检查通过！${NC}"
    fi

    # 更新PATH环境变量
    export PATH="/usr/local/bin:$PATH"
}

# 主执行流程
echo -e "${YELLOW}开始执行浏览器启动流程...${NC}"

# 先执行驱动检查
if ! check_drivers; then
    echo -e "${RED}驱动检查失败，退出脚本！${NC}"
    exit 1
fi

# 启动Chrome
echo -e "${YELLOW}正在启动Chrome...${NC}"
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
    --remote-debugging-port=9222 \
    --user-data-dir="$HOME/ChromeDebug" \
    https://polymarket.com/markets/crypto

echo -e "${GREEN}Chrome已成功启动！${NC}"