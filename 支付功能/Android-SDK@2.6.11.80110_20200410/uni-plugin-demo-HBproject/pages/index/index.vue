<template>
    <view>
        <button @click="beginScan">扫描设备</button>
		<button @click="beginPlay">开始投屏</button>
		
		<button @click="beginPay">开始购买</button>
		<button @click="endPay">结束购买</button>
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
			 const dcRichAlert = uni.requireNativePlugin('GooglePayWXModule'); 
		                // 使用插件  
		                dcRichAlert.show({  
		                    position: 'bottom',  
		                    title: "提示信息",  
		                    titleColor: '#FF0000',  
		                    content: "<a href='https://uniapp.dcloud.io/' value='Hello uni-app'>uni-app</a> 是一个使用 Vue.js 开发跨平台应用的前端框架!\n免费的\n免费的\n免费的\n重要的事情说三遍",  
		                    contentAlign: 'left',  
		                    checkBox: {  
		                        title: '不再提示',  
		                        isSelected: true  
		                    },  
		                    buttons: [{  
		                        title: '取消'  
		                    },  
		                    {  
		                        title: '否'  
		                    },  
		                    {  
		                        title: '确认',  
		                        titleColor: '#3F51B5'  
		                    }]  
		                }, result => {  
		                    switch (result.type) {  
		                        case 'button':  
		                            console.log("callback---button--" + result.index);  
		                        break;  
		                        case 'checkBox':  
		                            console.log("callback---checkBox--" + result.isSelected);  
		                        break;  
		                        case 'a':  
		                            console.log("callback---a--" + JSON.stringify(result));  
		                        break;  
		                        case 'backCancel':  
		                            console.log("callback---backCancel--");  
		                        break;  
		                   }  
		                });  
						},
		            
					
		beginPay(){
			
			const GooglePayWXModule = uni.requireNativePlugin('GooglePayWXModule');
			console.log(" 开始支付");
			GooglePayWXModule.showToast("this is running");
			// GooglePayWXModule.getResult(
			// {
			//     position: 'bottom',  
			//     title: "提示信息",  
			//     titleColor: '#FF0000',  
			//     content: "<a href='https://uniapp.dcloud.io/' value='Hello uni-app'>uni-app</a> 是一个使用 Vue.js 开发跨平台应用的前端框架!\n免费的\n免费的\n免费的\n重要的事情说三遍",  
			//     contentAlign: 'left'
			// 	},result => {  
		 //                   	console.log("  java 传过来的参数为" + result);
		 //                   }  
			// );

		},
		endPay(){
			
			
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
