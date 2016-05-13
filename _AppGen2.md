#Templates For artists to create apps.

发布到这里，可以同步安装到其他人机器上，只更新一份代码，用来创造app。

功能计划：
选择使用的打包运行壳环境。
提交素材、填写包名、广告ID等信息，生成游戏swf并加密，然后用壳子生成ipa／apk，并一键开始桌面测试和截图。

从2015/AppGenerator 逐步迁移过来。

## 发布APP流程
从开发环境下提取代码src目录，ane、swc等公用库到AppTemplates；
网页端，登陆后创建app，填入信息，创建一个文件夹到Generated目录下，存一个信息文件。
信息文件纪录所有要配置的id（包括 包名、百度广告ID、admob广告ID、项目特定的配置）。
一键发布时，PHP调用AIRSDK的工具打包，adl桌面测试。
所使用从AppTemplates里同步文件并替换信息文件中的配置，然后打包。
用户还需要上传自己做好的美术swc／mp3、icon、default; Icon只需要传1024尺寸的。


### 模块

- 创建项目

- descriptor.xml 生成
- Icon生成
- GameConf.as 篡改
- 调用各自项目的编译脚本
- 发布不同版本
