
ak 整理
https://juejin.im/post/5c85f2976fb9a049e232d42c
## 开发环境及工具
1. mac系统
2. [Xcode](去Mac 电脑的app store软件下载)
3. [HBuilderX](http://www.dcloud.io/hbuilderx.html)
4. [5+ SDK](http://ask.dcloud.net.cn/article/103)
5. [iOS平台 5+ SDK 参考手册](http://www.dcloud.io/docs/sdk/ios/)

## uni-app 插件扩展
### 创建项目
1. 创建一个uni-app项目，操作步骤：文件->新建->项目->选择uni-app->点击创建即可。
2. 创建js文件，可采用下方模板。已兼容5+ 插件开发。
~~~
! function(root, factory) {
	if (typeof exports == 'object' && typeof module != 'undefined') {
		module.exports = factory()
	} else if (typeof define == 'function' && define.amd) {
		define(factory)
	} else {
		// 5+ 兼容
		document.addEventListener('plusready', function(){
		// 修改此处为插件命名
		var moduleName = 'plugintest';
		// 挂载在plus下
		root.plus[moduleName] = factory()
		},false);
	}
}(this, function() {
	//在此处定义自己的方法
	var _BARCODE = 'plugintest';
	var plugintest = {
		/*方法已忽略，详细方法请参考SDK中的demo*/
	};
	return plugintest;
});
~~~
3. 插件引用。直接require即可（5+ 项目需使用script标签引入）。详细代码请下载附件，解压至任意目录，拖入HBuilderX即可。
4. 生成本地打包资源，导入Xcode工程。可参考：[HBuilderX 生成本地打包App资源](http://ask.dcloud.net.cn/question/60254)
### 插件编写
#### 用户可采用同步或异步的方式将结果通知到iOS端。
同步方法：
~~~
void plus.bridge.execSync( String service, String action, Array<String> args );
service: 插件类别名，对应dcloud_properties.xml的feature name。
action: 调用Native层插件方法名称。对应java文件的方法名。
args： 参数列表。
~~~
异步方法：
~~~
void plus.bridge.exec( String service, String action, Array<String> args );
service: 插件类别名，对应dcloud_properties.xml的feature name。
action: 调用Native层插件方法名称。对应java文件的方法名。
args： 参数列表。
~~~
#### 示例代码
~~~
var plugintest = {
    PluginTestFunctionArrayArgu: function(Argus, successCallback, errorCallback) {
        var success = typeof successCallback !== 'function' ? null : function(args) {
            successCallback(args);
        },
        fail = typeof errorCallback !== 'function' ? null : function(code) {
            errorCallback(code);
        };
        var callbackID = plus.bridge.callbackId(success, fail);
        return plus.bridge.exec(_BARCODE, "PluginTestFunctionArrayArgu", [callbackID, Argus]);
    }
};
~~~

## iOS 扩展插件
### 导入SDK工程到Xcode
1. 下载SDK包至任意目录。
2. 将SDK包中的HBuilder-Integrate项目用Xcode打开
### 编写插件
1. 创建一个类继承自PGPlugin类。
2. 实现方法，方法名**必须**与js方法中windows.plus.bridge.exec()或windows.plus.bridge.execSync()方法的第二个传入参数相同。
3. 方法中需存在一个PGMethod对象的参数。
4. 原生层执行完操作后会将数据异步返回到js层，可采取  -(void) toCallback: (NSString*) callbackId withReslut:(NSString*)message方法实现结果的传递。
~~~
/**
@brief 异步调用JavaScript回调函数
@param callbackId 回调ID
@param message JSON格式结果 参考:`toJSONString`
@return void
*/
-(void) toCallback: (NSString*) callbackId withReslut:(NSString*)message;

~~~
**其余方法可参考[iOS平台 5+ SDK 参考手册](http://www.dcloud.io/docs/sdk/ios/)**
### 代码示例
~~~
- (void)PluginTestFunctionArrayArgu:(PGMethod*)commands
{
if ( commands ) {

// CallBackid 异步方法的回调id，H5+ 会根据回调ID通知JS层运行结果成功或者失败
NSString* cbId = [commands.arguments objectAtIndex:0];

// 用户的参数会在第二个参数传回，可以按照Array方式传入，
NSArray* pArray = [commands.arguments objectAtIndex:1];

// 如果使用Array方式传递参数
NSString* pResultString = [NSString stringWithFormat:@"%@ %@ %@ %@",[pArray objectAtIndex:0], [pArray objectAtIndex:1], [pArray objectAtIndex:2], [pArray objectAtIndex:3]];

// 运行Native代码结果和预期相同，调用回调通知JS层运行成功并返回结果
PDRPluginResult *result = [PDRPluginResult resultWithStatus:PDRCommandStatusOK messageAsString:pResultString];

// 如果Native代码运行结果和预期不同，需要通过回调通知JS层出现错误，并返回错误提示
//PDRPluginResult *result = [PDRPluginResult resultWithStatus:PDRCommandStatusError messageAsString:@"惨了! 出错了！ 咋(wu)整(liao)"];

// 通知JS层Native层运行结果，JS Pluginbridge会根据cbid找到对应的回调方法并触发
[self toCallback:cbId withReslut:[result toJSONString]];
}
}
~~~

## 插件配置
1. 配置feature.plist文件，添加如下节点：
~~~
<key>plugintest</key>
<dict>
<key>class</key>
<string>PGPluginTest</string>
<key>global</key>
<true/>
</dict>
~~~
