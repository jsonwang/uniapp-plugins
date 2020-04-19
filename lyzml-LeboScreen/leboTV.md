使用说明：
本插件为简易版的乐播投屏功能，目前只支持安卓版，功能也很简单，目前只有
初始化：leboScreen.init();
扫描设备:leboScreen.startBrowse();
停止扫描:leboScreen.stopBrowse();
投屏:leboScreen.playVideo();
这几个接口；

1、首先需要在乐播官网(http://www.hpplay.com.cn/)注册申请移动应用，获得appid和appsecret；
2、在需要的页面上获取插件
const leboScreen = uni.requireNativePlugin("lyzml-LeboScreen");

3、初始化乐播插件，请至乐播官网申请appid和appsecret，本例中为测试说明参数
leboScreen.init({
	appId: "11111",
	appSecret: "23rdfsfsdfsdfsdfsdgfdvc"
});

4、开启扫描 leboScreen.startBrowse();

5、监听扫描返回结果：
_this.myEventManager = plus.android.importClass("com.coolanimals.listener.MyEventManager");
_this.eventManager = _this.myEventManager.getInstance();
_this.myListener = plus.android.implements("com.coolanimals.listener.MyListener", {
      onDataReceived: function(browseResult) {
		  console.log("=========browseResult=========", typeof(browseResult), browseResult);
		  if ("string" === typeof(browseResult)) {
		  	browseResult = JSON.parse(browseResult);
		  }
		  
		  if (1 == browseResult.code) {
			  if (browseResult.linkList && browseResult.linkList.length > 0) {
				  for(let i=0;i<browseResult.linkList.length;i++){
				  	  let br = browseResult.linkList[i];
					  //br为json对象，包含ip和name两个属性，作者是通过这两个属性来判断是否为同一设备的，之前用的uuid，但是有的设备没有这个属性
					  //这个扫描结果会多次返回同一个设备，所以前台页面接收显示的时候需要判断是否已经存在
					  
				  }
			  }
		  } else {
				uni.showToast({
					icon: "none",
					title: "扫描失败"
				});
	      }
	  }
});
		
_this.eventManager.addListener("onLeboMsgReceived", _this.myListener); 
 
注：com.coolanimals.listener.MyEventManager和com.coolanimals.listener.MyListener这两个类是自定义的，用来返回数据给前台；

6、停止扫描接口：leboScreen.stopBrowse();

7、投屏接口,目前只支持投屏视频
leboScreen.playVideo({
	"videoUrl": _this.onloadParams.videoUrl,  //投屏的视频地址
	"ip": _this.tvip,                         //扫描返回的设备ip
	"name": _this.tvname                      //扫描返回的设备名称
});