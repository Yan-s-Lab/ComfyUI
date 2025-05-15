#!/bin/bash

# 设置变量
DOCKER_USERNAME=${DOCKER_USERNAME:-"your-username"}
IMAGE_NAME="comfyui-boot"
TAG=${TAG:-"latest"}

# 显示帮助信息
show_help() {
    echo "使用方法: $0 [选项]"
    echo "选项:"
    echo "  -h, --help                显示帮助信息"
    echo "  -u, --username USERNAME   设置Docker Hub用户名 (默认: $DOCKER_USERNAME)"
    echo "  -t, --tag TAG             设置镜像标签 (默认: $TAG)"
    echo "  -g, --github              推送到GitHub Container Registry"
    echo "  -d, --dockerhub           推送到Docker Hub"
    echo "  -b, --build-only          仅构建镜像，不推送"
    echo "  --no-cache                构建时不使用缓存"
    exit 0
}

# 解析命令行参数
PUSH_TO_GITHUB=false
PUSH_TO_DOCKERHUB=false
BUILD_ONLY=false
NO_CACHE=""

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -h|--help)
            show_help
            ;;
        -u|--username)
            DOCKER_USERNAME="$2"
            shift
            shift
            ;;
        -t|--tag)
            TAG="$2"
            shift
            shift
            ;;
        -g|--github)
            PUSH_TO_GITHUB=true
            shift
            ;;
        -d|--dockerhub)
            PUSH_TO_DOCKERHUB=true
            shift
            ;;
        -b|--build-only)
            BUILD_ONLY=true
            shift
            ;;
        --no-cache)
            NO_CACHE="--no-cache"
            shift
            ;;
        *)
            echo "未知选项: $1"
            show_help
            ;;
    esac
done

# 如果没有指定推送目标，则默认只构建
if [ "$PUSH_TO_GITHUB" = false ] && [ "$PUSH_TO_DOCKERHUB" = false ]; then
    BUILD_ONLY=true
fi

# 构建镜像
echo "正在构建 $DOCKER_USERNAME/$IMAGE_NAME:$TAG 镜像..."
docker build $NO_CACHE -t $DOCKER_USERNAME/$IMAGE_NAME:$TAG .

# 如果只构建，则退出
if [ "$BUILD_ONLY" = true ]; then
    echo "镜像构建完成: $DOCKER_USERNAME/$IMAGE_NAME:$TAG"
    exit 0
fi

# 推送到Docker Hub
if [ "$PUSH_TO_DOCKERHUB" = true ]; then
    echo "正在登录到Docker Hub..."
    docker login
    
    echo "正在推送镜像到Docker Hub..."
    docker push $DOCKER_USERNAME/$IMAGE_NAME:$TAG
    
    echo "镜像已成功推送到Docker Hub: $DOCKER_USERNAME/$IMAGE_NAME:$TAG"
fi

# 推送到GitHub Container Registry
if [ "$PUSH_TO_GITHUB" = true ]; then
    echo "正在登录到GitHub Container Registry..."
    echo "请输入你的GitHub个人访问令牌:"
    read -s GITHUB_TOKEN
    echo $GITHUB_TOKEN | docker login ghcr.io -u $DOCKER_USERNAME --password-stdin
    
    echo "正在标记镜像用于GitHub Container Registry..."
    docker tag $DOCKER_USERNAME/$IMAGE_NAME:$TAG ghcr.io/$DOCKER_USERNAME/$IMAGE_NAME:$TAG
    
    echo "正在推送镜像到GitHub Container Registry..."
    docker push ghcr.io/$DOCKER_USERNAME/$IMAGE_NAME:$TAG
    
    echo "镜像已成功推送到GitHub Container Registry: ghcr.io/$DOCKER_USERNAME/$IMAGE_NAME:$TAG"
fi

echo "操作完成!"
