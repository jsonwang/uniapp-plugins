<template>
    <view>
        <button @click="beginScan">扫描设备</button>
		<button @click="beginPlay">开始投屏</button>
		
		<button @click="beginPay">初始化购买工具类</button>
		<button @click="endPay">买一个商品</button>
		<button @click="PayInapp"> 购买内购</button>
		<button @click="PaySubscript">购买订阅</button>
		<button @click="showRichAlert">showRichAlert</button>
	 
    </view>
</template>
<style>
	button {
		width: 94%;
		margin: 20upx auto;
	}
</style>
<script>
	
// 下面 是测试代码	
export default {
    methods: {
		 // require插件名称  
		 
		showRichAlert() {  
			 },
					
		beginPay(){
			
			const dcRichAlert = uni.requireNativePlugin('GooglePayWXModule');
			           // 使用插件  
			           dcRichAlert.createPayCenter({  
			               
			      //          INAPP: [
							  //  "video1",
							  //  "video2",
							  //  "video3"
						   // ]  ,
						   SUBS: [
							   "welovip_1",
							   "welovip_3",
							   "welovip_12"

						       ]  
			           }, result => {  

									// {"code":"0","debugMessage":"网络错误！"}  code == 0 时为成功 其它值时为失败
									// 只有返回成功时才能调用购买接口
			                       console.log("初始化结果为:"+result);  
			                   
			              }  
			           ); 

		},
		endPay(){
			
			const dcRichAlert = uni.requireNativePlugin('GooglePayWXModule');
			           // 使用插件  
			           dcRichAlert.paySKU({  
			               
			               SKU:"welovip_1" 
			           }, result => {  
			
			             
			                   console.log("购买结果为:"+result);  
			                   
			              }  
			           ); 
			
		},
		PayInapp(){
			
			
		},
		
		PaySubscript(){
			
			
		},
		
		
		// 初始化并扫描周边可用设备 
		beginScan(){
			const leboPlugins = uni.requireNativePlugin('liblebo-new');
		    console.log(" 开始扫描设备");
			leboPlugins.LBBeginSerach({
			                    LBAPPID: '13357',  
			                    LBSECRETKEY: "265eece11c84d13cb1872281969d2932"
			               
			                }, result => {  
								//这里是一个字典 key是 设备名 value 是设备 ip 在调用播放的时候要使用Ip，
								//注意这个字典 key 真有可能重复要去重
								console.log("发现的设备"+Object.keys(result))

			                });

		},
		
		//播放指定视频
		beginPlay(){
			
			leboPlugins.stopSearch();
			
		    console.log(" 开始投屏播放");
			const leboPlugins = uni.requireNativePlugin('liblebo-new');
			leboPlugins.LBBeginPlaying({
			                    url: 'http://hpplay.cdn.cibn.cc/videos/03.mp4',  
			                    ipAddress: "192.168.1.103"
			                    
			                }, result => {  
			
								console.log("播放结果"+result);
			              
			                });
		}
    }
};
</script>
<style>
</style>
