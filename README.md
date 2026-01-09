# Docker Images Pusher

使用Github Action将国外的Docker镜像转存到阿里云私有仓库，供国内服务器使用，免费易用<br>
- 支持DockerHub, gcr.io, k8s.io, ghcr.io等任意仓库<br>
- 支持最大40GB的大型镜像<br>
- 使用阿里云的官方线路，速度快<br>

视频教程：https://www.bilibili.com/video/BV1Zn4y19743/

作者：**[技术爬爬虾](https://github.com/tech-shrimp/me)**<br>
B站，抖音，Youtube全网同名，转载请注明作者<br>

## 使用方式


### 配置阿里云
登录阿里云容器镜像服务<br>
https://cr.console.aliyun.com/<br>
启用个人实例，创建一个命名空间（**ALIYUN_NAME_SPACE**）
![](/doc/命名空间.png)

访问凭证–>获取环境变量<br>
用户名（**ALIYUN_REGISTRY_USER**)<br>
密码（**ALIYUN_REGISTRY_PASSWORD**)<br>
仓库地址（**ALIYUN_REGISTRY**）<br>

![](/doc/用户名密码.png)


### Fork本项目
Fork本项目<br>
#### 启动Action
进入您自己的项目，点击Action，启用Github Action功能<br>
#### 配置环境变量
进入Settings->Secret and variables->Actions->New Repository secret
![](doc/配置环境变量.png)
将上一步的**四个值**<br>
ALIYUN_NAME_SPACE,ALIYUN_REGISTRY_USER，ALIYUN_REGISTRY_PASSWORD，ALIYUN_REGISTRY<br>
配置成环境变量

### 添加镜像
打开images.txt文件，添加你想要的镜像 
可以加tag，也可以不用(默认latest)<br>
可添加 --platform=xxxxx 的参数指定镜像架构<br>
可使用 k8s.gcr.io/kube-state-metrics/kube-state-metrics 格式指定私库<br>
可使用 #开头作为注释<br>
![](doc/images.png)
文件提交后，自动进入Github Action构建

### 使用镜像
回到阿里云，镜像仓库，点击任意镜像，可查看镜像状态。(可以改成公开，拉取镜像免登录)
![](doc/开始使用.png)

在国内服务器pull镜像, 例如：<br>
```
docker pull registry.cn-hangzhou.aliyuncs.com/shrimp-images/alpine
```
registry.cn-hangzhou.aliyuncs.com 即 ALIYUN_REGISTRY(阿里云仓库地址)<br>
shrimp-images 即 ALIYUN_NAME_SPACE(阿里云命名空间)<br>
alpine 即 阿里云中显示的镜像名<br>

### 多架构
需要在images.txt中用 --platform=xxxxx手动指定镜像架构
指定后的架构会以前缀的形式放在镜像名字前面
![](doc/多架构.png)

### 镜像重名
程序自动判断是否存在名称相同, 但是属于不同命名空间的情况。
如果存在，会把命名空间作为前缀加在镜像名称前。
例如:
```
xhofe/alist
xiaoyaliu/alist
```
![](doc/镜像重名.png)

### 定时执行
修改/.github/workflows/docker.yaml文件
添加 schedule即可定时执行(此处cron使用UTC时区)
![](doc/定时执行.png)

### 从 Dockerfile 构建镜像
除了拉取现有镜像外，还支持从 Dockerfile 构建镜像并推送到阿里云。

#### 配置构建参数
编辑 `docker-build.txt` 文件，每行配置一个镜像的构建信息。

格式：`镜像名称 Dockerfile路径 构建上下文 额外的标签`

参数说明：
- **镜像名称**：推送到阿里云的镜像名称（必需）
- **Dockerfile路径**：Dockerfile 文件的相对路径（可选，默认为 ./Dockerfile）
- **构建上下文**：构建上下文的路径（可选，默认为 .）
- **额外的标签**：额外的镜像标签，格式为 `--tag 镜像名:标签`（可选）

示例：
```
my-app ./Dockerfile . --tag my-app:v1.0 --tag my-app:stable
web-app ./web/Dockerfile ./web --tag web-app:latest
```

#### 创建 Dockerfile
在项目根目录或指定路径创建 Dockerfile。可以参考 `Dockerfile.example` 示例文件。

#### 触发构建
修改以下任一文件后会自动触发构建：
- `Dockerfile`
- `docker-build.txt`
- `.github/workflows/docker-build.yaml`

也可以在 GitHub Actions 页面手动触发 `Docker Build` workflow。

#### 多架构支持
默认构建 linux/amd64 和 linux/arm64 两种架构的镜像。如需修改架构，编辑 `.github/workflows/docker-build.yaml` 文件中的 `--platform` 参数。
