<template>
    <view>
        <button @click="beginScan">扫描设备</button>
		<button @click="beginPlay">开始投屏</button>
	 
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
