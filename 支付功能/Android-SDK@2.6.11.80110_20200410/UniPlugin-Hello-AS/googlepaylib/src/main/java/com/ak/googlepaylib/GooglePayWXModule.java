package com.ak.googlepaylib;

import android.util.Log;
import android.widget.Toast;

import com.taobao.weex.WXSDKEngine;
import com.taobao.weex.annotation.JSMethod;
import com.taobao.weex.bridge.JSCallback;

import org.json.JSONObject;

import java.util.HashMap;
import java.util.List;
import java.util.Map;


public class GooglePayWXModule extends WXSDKEngine.DestroyableModule {


    @JSMethod(uiThread = true)
    public void showToast(String msg){
        Toast.makeText(mWXSDKInstance.getContext(),msg,Toast.LENGTH_SHORT).show();
    }


    private JSCallback myCallback;
    @JSMethod(uiThread = true)
    public void getResult(JSONObject options, JSCallback jsCallback){
        myCallback = jsCallback;
        Map<String, Object> map = new HashMap<>();
        try{
            Object name = "yang";//默认姓名
            Object sex = "man";//默认性别
            name = options.get("name") == null ? name : options.get("name");
            sex = options.get("sex") == null ? sex : options.get("sex");
            Log.d("liyliyliy", name.toString() + "，" + sex.toString());
            map.put("success","true");
            map.put("姓名",name.toString());
            map.put("性别",sex.toString());
            myCallback.invoke(map);
        }catch (Exception e){
            map.put("fail:",e.getMessage());
            map.put("姓名","");
            map.put("性别","");
            myCallback.invoke(map);
        }
    }

    @Override
    public void destroy() {

    }

}
