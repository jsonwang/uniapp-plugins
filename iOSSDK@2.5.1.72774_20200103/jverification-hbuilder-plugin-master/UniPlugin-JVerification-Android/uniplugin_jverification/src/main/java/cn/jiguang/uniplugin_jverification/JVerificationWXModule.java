package cn.jiguang.uniplugin_jverification;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.taobao.weex.WXSDKEngine;
import com.taobao.weex.annotation.JSMethod;
import com.taobao.weex.bridge.JSCallback;


import cn.jiguang.uniplugin_jverification.common.JConstants;
import cn.jiguang.uniplugin_jverification.common.JLogger;
import cn.jiguang.verifysdk.api.AuthPageEventListener;
import cn.jiguang.verifysdk.api.JVerificationInterface;
import cn.jiguang.verifysdk.api.JVerifyUIConfig;
import cn.jiguang.verifysdk.api.LoginSettings;
import cn.jiguang.verifysdk.api.PreLoginListener;
import cn.jiguang.verifysdk.api.RequestCallback;
import cn.jiguang.verifysdk.api.VerifyListener;

public class JVerificationWXModule extends WXSDKEngine.DestroyableModule {

    @JSMethod(uiThread = true)
    public void setDebugMode(boolean enable) {
        JVerificationInterface.setDebugMode(enable);
        JLogger.setLoggerEnable(enable);

    }

    @JSMethod(uiThread = true)
    public void init(JSONObject object,final JSCallback jsCallback) {
        int timeout = object.containsKey("timeout")?object.getIntValue("timeout"):10000;
        JLogger.d("init with timeout set:" + timeout);
        JVerificationInterface.init(mWXSDKInstance.getContext().getApplicationContext(),timeout, new RequestCallback<String>() {
            @Override
            public void onResult(int code, String content) {
                if (jsCallback == null) return;
                jsCallback.invoke(convertToResult(code, content));
            }
        });
    }


    @JSMethod(uiThread = true)
    public void isInitSuccess(JSCallback callback) {
        boolean succ =JVerificationInterface.isInitSuccess();
        JLogger.d("isInitSuccess:" + succ);
        if (callback == null) return;
        callback.invoke(convertToResult(succ));
    }

    @JSMethod(uiThread = true)
    public void checkVerifyEnable(JSCallback callback) {
        boolean enable =JVerificationInterface.checkVerifyEnable(mWXSDKInstance.getContext());
        JLogger.d("checkVerifyEnable:" + enable);
        if (callback == null) return;
        callback.invoke(convertToResult(enable));
    }

    @JSMethod(uiThread = true)
    public void getToken(int timeout, final JSCallback callback) {
        JLogger.d("getToken with timeout set:" + timeout);
        JVerificationInterface.getToken(mWXSDKInstance.getContext(), timeout, new VerifyListener() {
            @Override
            public void onResult(int code, String content, String operator) {
                if (callback == null) return;
                callback.invoke(convertToResult(code, content, operator));
            }
        });
    }

    @JSMethod(uiThread = true)
    public void preLogin(int timeout, final JSCallback callback) {
        JLogger.d("preLogin with timeout set:" + timeout);
        JVerificationInterface.preLogin(mWXSDKInstance.getContext(), timeout, new PreLoginListener() {
            @Override
            public void onResult(int code, String content) {
                if (callback == null) return;
                callback.invoke(convertToResult(code, content));
            }
        });
    }

    @JSMethod(uiThread = true)
    public void clearPreLoginCache() {
        JLogger.d("clearPreLoginCache");
        JVerificationInterface.clearPreLoginCache();
    }

    @JSMethod(uiThread = true)
    public void loginAuth(JSONObject object, final JSCallback callback, final JSCallback eventCallback) {
        int timeout = 10000;
        boolean autoFinish = true;
        if (object != null) {
            timeout = object.containsKey(JConstants.TIME_OUT) ? object.getIntValue(JConstants.TIME_OUT) : 10000;
            autoFinish = object.containsKey(JConstants.AUTO_FINISH) ? object.getBooleanValue(JConstants.AUTO_FINISH) : true;
        }
        JLogger.d("loginAuth with setting autoFinish:" + autoFinish + " timeout:" + timeout);
        LoginSettings settings = new LoginSettings();
        settings.setAutoFinish(autoFinish);//设置登录完成后是否自动关闭授权页
        settings.setTimeout(timeout);//设置超时时间，单位毫秒。 合法范围（0，30000],范围以外默认设置为10000

        settings.setAuthPageEventListener(new AuthPageEventListener() {
            @Override
            public void onEvent(int cmd, String msg) {
                eventCallback.invokeAndKeepAlive(convertToResult(cmd, msg));
            }
        });//设置授权页事件监听
        JVerificationInterface.loginAuth(mWXSDKInstance.getContext(), settings, new VerifyListener() {
            @Override
            public void onResult(int code, String content, String operator) {
                callback.invoke(convertToResult(code, content, operator));
            }
        });
    }


    @JSMethod(uiThread = true)
    public void dismissLoginAuth(boolean needCloseAnim, final JSCallback callback) {
        JLogger.d("dismissLoginAuth:"+needCloseAnim);
        JVerificationInterface.dismissLoginAuthActivity(needCloseAnim, new RequestCallback<String>() {
            @Override
            public void onResult(int code, String desc) {
                callback.invoke(convertToResult(code, desc));
            }
        });
    }


    @JSMethod(uiThread = true)
    public void setCustomUIWithConfigAndroid(JSONObject jsonObjectPortrait, JSONObject jsonObjectLandscape) {

        if(jsonObjectLandscape == null){
            JLogger.d("setCustomUIWithConfigAndroid all");
            JVerifyUIConfig.Builder uiConfig = getBuilder(jsonObjectPortrait);
            JVerificationInterface.setCustomUIWithConfig(uiConfig.build());
        }else{
            JLogger.d("setCustomUIWithConfigAndroid portrait and landscape");
            JVerifyUIConfig.Builder uiConfigPortrait = getBuilder(jsonObjectPortrait);
            JVerifyUIConfig.Builder uiConfigLandscape = getBuilder(jsonObjectLandscape);
            JVerificationInterface.setCustomUIWithConfig(uiConfigPortrait.build(), uiConfigLandscape.build());
        }


    }


    private JVerifyUIConfig.Builder getBuilder(JSONObject jsonObject) {

        JVerifyUIConfig.Builder uiConfigBuilder = new JVerifyUIConfig.Builder();
        setUiConfig(uiConfigBuilder, jsonObject);
        return uiConfigBuilder;
    }

    private void setUiConfig(JVerifyUIConfig.Builder uiConfigBuilder, JSONObject jsonObject) {
        //  设置授权页背景
        if (jsonObject.containsKey(JConstants.setAuthBGImgPath)) {
            uiConfigBuilder.setAuthBGImgPath(jsonObject.getString(JConstants.setAuthBGImgPath));
        }
        // 状态栏
        if (jsonObject.containsKey(JConstants.setStatusBarColorWithNav)) {
            uiConfigBuilder.setStatusBarColorWithNav(jsonObject.getBooleanValue(JConstants.setStatusBarColorWithNav));
        }
        if (jsonObject.containsKey(JConstants.setStatusBarDarkMode)) {
            uiConfigBuilder.setStatusBarDarkMode(jsonObject.getBooleanValue(JConstants.setStatusBarDarkMode));
        }
        if (jsonObject.containsKey(JConstants.setStatusBarTransparent)) {
            uiConfigBuilder.setStatusBarTransparent(jsonObject.getBooleanValue(JConstants.setStatusBarTransparent));
        }
        if (jsonObject.containsKey(JConstants.setStatusBarHidden)) {
            uiConfigBuilder.setStatusBarHidden(jsonObject.getBooleanValue(JConstants.setStatusBarHidden));
        }
        if (jsonObject.containsKey(JConstants.setVirtualButtonTransparent)) {
            uiConfigBuilder.setVirtualButtonTransparent(jsonObject.getBooleanValue(JConstants.setVirtualButtonTransparent));
        }
        //  授权页导航栏
        if (jsonObject.containsKey(JConstants.setNavColor)) {
            uiConfigBuilder.setNavColor(jsonObject.getIntValue(JConstants.setNavColor));
        }
        if (jsonObject.containsKey(JConstants.setNavText)) {
            uiConfigBuilder.setNavText(jsonObject.getString(JConstants.setNavText));
        }
        if (jsonObject.containsKey(JConstants.setNavTextColor)) {
            uiConfigBuilder.setNavTextColor(jsonObject.getIntValue(JConstants.setNavTextColor));
        }
        if (jsonObject.containsKey(JConstants.setNavReturnImgPath)) {
            uiConfigBuilder.setNavReturnImgPath(jsonObject.getString(JConstants.setNavReturnImgPath));
        }
        if (jsonObject.containsKey(JConstants.setNavTransparent)) {
            uiConfigBuilder.setNavTransparent(jsonObject.getBooleanValue(JConstants.setNavTransparent));
        }
        if (jsonObject.containsKey(JConstants.setNavTextSize)) {
            uiConfigBuilder.setNavTextSize(jsonObject.getIntValue(JConstants.setNavTextSize));
        }
        if (jsonObject.containsKey(JConstants.setNavReturnBtnHidden)) {
            uiConfigBuilder.setNavReturnBtnHidden(jsonObject.getBooleanValue(JConstants.setNavReturnBtnHidden));
        }
        if (jsonObject.containsKey(JConstants.setNavReturnBtnWidth)) {
            uiConfigBuilder.setNavReturnBtnWidth(jsonObject.getIntValue(JConstants.setNavReturnBtnWidth));
        }
        if (jsonObject.containsKey(JConstants.setNavReturnBtnHeight)) {
            uiConfigBuilder.setNavReturnBtnHeight(jsonObject.getIntValue(JConstants.setNavReturnBtnHeight));
        }
        if (jsonObject.containsKey(JConstants.setNavReturnBtnOffsetX)) {
            uiConfigBuilder.setNavReturnBtnOffsetX(jsonObject.getIntValue(JConstants.setNavReturnBtnOffsetX));
        }
        if (jsonObject.containsKey(JConstants.setNavReturnBtnRightOffsetX)) {
            uiConfigBuilder.setNavReturnBtnRightOffsetX(jsonObject.getIntValue(JConstants.setNavReturnBtnRightOffsetX));
        }
        if (jsonObject.containsKey(JConstants.setNavReturnBtnOffsetY)) {
            uiConfigBuilder.setNavReturnBtnOffsetY(jsonObject.getIntValue(JConstants.setNavReturnBtnOffsetY));
        }
        if (jsonObject.containsKey(JConstants.setNavHidden)) {
            uiConfigBuilder.setNavHidden(jsonObject.getBooleanValue(JConstants.setNavHidden));
        }

        //  授权页logo
        if (jsonObject.containsKey(JConstants.setLogoWidth)) {
            uiConfigBuilder.setLogoWidth(jsonObject.getIntValue(JConstants.setLogoWidth));
        }
        if (jsonObject.containsKey(JConstants.setLogoHeight)) {
            uiConfigBuilder.setLogoHeight(jsonObject.getIntValue(JConstants.setLogoHeight));
        }
        if (jsonObject.containsKey(JConstants.setLogoHidden)) {
            uiConfigBuilder.setLogoHidden(jsonObject.getBooleanValue(JConstants.setLogoHidden));
        }
        if (jsonObject.containsKey(JConstants.setLogoOffsetY)) {
            uiConfigBuilder.setLogoOffsetY(jsonObject.getIntValue(JConstants.setLogoOffsetY));
        }
        if (jsonObject.containsKey(JConstants.setLogoImgPath)) {
            uiConfigBuilder.setLogoImgPath(jsonObject.getString(JConstants.setLogoImgPath));
        }
        if (jsonObject.containsKey(JConstants.setLogoOffsetX)) {
            uiConfigBuilder.setLogoOffsetX(jsonObject.getIntValue(JConstants.setLogoOffsetX));
        }
        if (jsonObject.containsKey(JConstants.setLogoOffsetBottomY)) {
            uiConfigBuilder.setLogoOffsetBottomY(jsonObject.getIntValue(JConstants.setLogoOffsetBottomY));
        }

        //  授权页号码栏
        if (jsonObject.containsKey(JConstants.setNumberColor)) {
            uiConfigBuilder.setNumberColor(jsonObject.getIntValue(JConstants.setNumberColor));
        }
        if (jsonObject.containsKey(JConstants.setNumberSize)) {
            uiConfigBuilder.setNumberSize(jsonObject.getIntValue(JConstants.setNumberSize));
        }
        if (jsonObject.containsKey(JConstants.setNumFieldOffsetY)) {
            uiConfigBuilder.setNumFieldOffsetY(jsonObject.getIntValue(JConstants.setNumFieldOffsetY));
        }
        if (jsonObject.containsKey(JConstants.setNumFieldOffsetX)) {
            uiConfigBuilder.setNumFieldOffsetX(jsonObject.getIntValue(JConstants.setNumFieldOffsetX));
        }
        if (jsonObject.containsKey(JConstants.setNumberFieldOffsetBottomY)) {
            uiConfigBuilder.setNumberFieldOffsetBottomY(jsonObject.getIntValue(JConstants.setNumberFieldOffsetBottomY));
        }
        if (jsonObject.containsKey(JConstants.setNumberFieldWidth)) {
            uiConfigBuilder.setNumberFieldWidth(jsonObject.getIntValue(JConstants.setNumberFieldWidth));
        }
        if (jsonObject.containsKey(JConstants.setNumberFieldHeight)) {
            uiConfigBuilder.setNumberFieldHeight(jsonObject.getIntValue(JConstants.setNumberFieldHeight));
        }


        //  授权页登录按钮
        if (jsonObject.containsKey(JConstants.setLogBtnText)) {
            uiConfigBuilder.setLogBtnText(jsonObject.getString(JConstants.setLogBtnText));
        }
        if (jsonObject.containsKey(JConstants.setLogBtnTextColor)) {
            uiConfigBuilder.setLogBtnTextColor(jsonObject.getIntValue(JConstants.setLogBtnTextColor));
        }
        if (jsonObject.containsKey(JConstants.setLogBtnImgPath)) {
            uiConfigBuilder.setLogBtnImgPath(jsonObject.getString(JConstants.setLogBtnImgPath));
        }
        if (jsonObject.containsKey(JConstants.setLogBtnOffsetY)) {
            uiConfigBuilder.setLogBtnOffsetY(jsonObject.getIntValue(JConstants.setLogBtnOffsetY));
        }
        if (jsonObject.containsKey(JConstants.setLogBtnOffsetX)) {
            uiConfigBuilder.setLogBtnOffsetX(jsonObject.getIntValue(JConstants.setLogBtnOffsetX));
        }
        if (jsonObject.containsKey(JConstants.setLogBtnWidth)) {
            uiConfigBuilder.setLogBtnWidth(jsonObject.getIntValue(JConstants.setLogBtnWidth));
        }
        if (jsonObject.containsKey(JConstants.setLogBtnHeight)) {
            uiConfigBuilder.setLogBtnHeight(jsonObject.getIntValue(JConstants.setLogBtnHeight));
        }
        if (jsonObject.containsKey(JConstants.setLogBtnTextSize)) {
            uiConfigBuilder.setLogBtnTextSize(jsonObject.getIntValue(JConstants.setLogBtnTextSize));
        }
        if (jsonObject.containsKey(JConstants.setLogBtnBottomOffsetY)) {
            uiConfigBuilder.setLogBtnBottomOffsetY(jsonObject.getIntValue(JConstants.setLogBtnBottomOffsetY));
        }

        //  授权页隐私栏
        if (jsonObject.containsKey(JConstants.setAppPrivacyOne)) {
            JSONArray jsonArraySetAppPrivacyOne = jsonObject.getJSONArray(JConstants.setAppPrivacyOne);
            uiConfigBuilder.setAppPrivacyOne(jsonArraySetAppPrivacyOne.getString(0), jsonArraySetAppPrivacyOne.getString(1));
        }
        if (jsonObject.containsKey(JConstants.setAppPrivacyTwo)) {
            JSONArray jsonArraySetAppPrivacyTwo = jsonObject.getJSONArray(JConstants.setAppPrivacyTwo);
            uiConfigBuilder.setAppPrivacyTwo(jsonArraySetAppPrivacyTwo.getString(0), jsonArraySetAppPrivacyTwo.getString(1));
        }
        if (jsonObject.containsKey(JConstants.setAppPrivacyColor)) {
            JSONArray jsonArraySetAppPrivacyColor = jsonObject.getJSONArray(JConstants.setAppPrivacyColor);
            uiConfigBuilder.setAppPrivacyColor(jsonArraySetAppPrivacyColor.getIntValue(0), jsonArraySetAppPrivacyColor.getIntValue(1));
        }
        if (jsonObject.containsKey(JConstants.setPrivacyOffsetY)) {
            uiConfigBuilder.setPrivacyOffsetY(jsonObject.getIntValue(JConstants.setPrivacyOffsetY));
        }
        if (jsonObject.containsKey(JConstants.setCheckedImgPath)) {
            uiConfigBuilder.setCheckedImgPath(jsonObject.getString(JConstants.setCheckedImgPath));
        }
        if (jsonObject.containsKey(JConstants.setUncheckedImgPath)) {
            uiConfigBuilder.setUncheckedImgPath(jsonObject.getString(JConstants.setUncheckedImgPath));
        }
        if (jsonObject.containsKey(JConstants.setPrivacyState)) {
            uiConfigBuilder.setPrivacyState(jsonObject.getBooleanValue(JConstants.setPrivacyState));
        }
        if (jsonObject.containsKey(JConstants.setPrivacyOffsetX)) {
            uiConfigBuilder.setPrivacyOffsetX(jsonObject.getIntValue(JConstants.setPrivacyOffsetX));
        }
        if (jsonObject.containsKey(JConstants.setPrivacyTextCenterGravity)) {
            uiConfigBuilder.setPrivacyTextCenterGravity(jsonObject.getBooleanValue(JConstants.setPrivacyTextCenterGravity));
        }
        if (jsonObject.containsKey(JConstants.setPrivacyText)) {
            JSONArray jsonArray = jsonObject.getJSONArray(JConstants.setPrivacyText);
            uiConfigBuilder.setPrivacyText(jsonArray.getString(0), jsonArray.getString(1), jsonArray.getString(2), jsonArray.getString(3));
        }
        if (jsonObject.containsKey(JConstants.setPrivacyTextSize)) {
            uiConfigBuilder.setPrivacyTextSize(jsonObject.getIntValue(JConstants.setPrivacyTextSize));
        }
        if (jsonObject.containsKey(JConstants.setPrivacyTopOffsetY)) {
            uiConfigBuilder.setPrivacyTopOffsetY(jsonObject.getIntValue(JConstants.setPrivacyTopOffsetY));
        }
        if (jsonObject.containsKey(JConstants.setPrivacyCheckboxHidden)) {
            uiConfigBuilder.setPrivacyCheckboxHidden(jsonObject.getBooleanValue(JConstants.setPrivacyCheckboxHidden));
        }
        if (jsonObject.containsKey(JConstants.setPrivacyCheckboxSize)) {
            uiConfigBuilder.setPrivacyCheckboxSize(jsonObject.getIntValue(JConstants.setPrivacyCheckboxSize));
        }
        if (jsonObject.containsKey(JConstants.setPrivacyWithBookTitleMark)) {
            uiConfigBuilder.setPrivacyWithBookTitleMark(jsonObject.getBooleanValue(JConstants.setPrivacyWithBookTitleMark));
        }
        if (jsonObject.containsKey(JConstants.setPrivacyCheckboxInCenter)) {
            uiConfigBuilder.setPrivacyCheckboxInCenter(jsonObject.getBooleanValue(JConstants.setPrivacyCheckboxInCenter));
        }
        if (jsonObject.containsKey(JConstants.setPrivacyTextWidth)) {
            uiConfigBuilder.setPrivacyTextWidth(jsonObject.getIntValue(JConstants.setPrivacyTextWidth));
        }

        //  授权页隐私协议web页面
        if (jsonObject.containsKey(JConstants.setPrivacyNavColor)) {
            uiConfigBuilder.setPrivacyNavColor(jsonObject.getIntValue(JConstants.setPrivacyNavColor));
        }
        if (jsonObject.containsKey(JConstants.setPrivacyNavTitleTextColor)) {
            uiConfigBuilder.setPrivacyNavTitleTextColor(jsonObject.getIntValue(JConstants.setPrivacyNavTitleTextColor));
        }
        if (jsonObject.containsKey(JConstants.setPrivacyNavTitleTextSize)) {
            uiConfigBuilder.setPrivacyNavTitleTextSize(jsonObject.getIntValue(JConstants.setPrivacyNavTitleTextSize));
        }
        if (jsonObject.containsKey(JConstants.setAppPrivacyNavTitle1)) {
            uiConfigBuilder.setAppPrivacyNavTitle1(jsonObject.getString(JConstants.setAppPrivacyNavTitle1));
        }
        if (jsonObject.containsKey(JConstants.setAppPrivacyNavTitle2)) {
            uiConfigBuilder.setAppPrivacyNavTitle2(jsonObject.getString(JConstants.setAppPrivacyNavTitle2));
        }
        if (jsonObject.containsKey(JConstants.setPrivacyStatusBarColorWithNav)) {
            uiConfigBuilder.setPrivacyStatusBarColorWithNav(jsonObject.getBooleanValue(JConstants.setPrivacyStatusBarColorWithNav));
        }
        if (jsonObject.containsKey(JConstants.setPrivacyStatusBarDarkMode)) {
            uiConfigBuilder.setPrivacyStatusBarDarkMode(jsonObject.getBooleanValue(JConstants.setPrivacyStatusBarDarkMode));
        }
        if (jsonObject.containsKey(JConstants.setPrivacyStatusBarTransparent)) {
            uiConfigBuilder.setPrivacyStatusBarTransparent(jsonObject.getBooleanValue(JConstants.setPrivacyStatusBarTransparent));
        }
        if (jsonObject.containsKey(JConstants.setPrivacyStatusBarHidden)) {
            uiConfigBuilder.setPrivacyStatusBarHidden(jsonObject.getBooleanValue(JConstants.setPrivacyStatusBarHidden));
        }
        if (jsonObject.containsKey(JConstants.setPrivacyVirtualButtonTransparent)) {
            uiConfigBuilder.setPrivacyVirtualButtonTransparent(jsonObject.getBooleanValue(JConstants.setPrivacyVirtualButtonTransparent));
        }

        //  授权页slogan
        if (jsonObject.containsKey(JConstants.setSloganTextColor)) {
            uiConfigBuilder.setSloganTextColor(jsonObject.getIntValue(JConstants.setSloganTextColor));
        }
        if (jsonObject.containsKey(JConstants.setSloganOffsetY)) {
            uiConfigBuilder.setSloganOffsetY(jsonObject.getIntValue(JConstants.setSloganOffsetY));
        }
        if (jsonObject.containsKey(JConstants.setSloganOffsetX)) {
            uiConfigBuilder.setSloganOffsetX(jsonObject.getIntValue(JConstants.setSloganOffsetX));
        }
        if (jsonObject.containsKey(JConstants.setSloganBottomOffsetY)) {
            uiConfigBuilder.setSloganBottomOffsetY(jsonObject.getIntValue(JConstants.setSloganBottomOffsetY));
        }
        if (jsonObject.containsKey(JConstants.setSloganTextSize)) {
            uiConfigBuilder.setSloganTextSize(jsonObject.getIntValue(JConstants.setSloganTextSize));
        }
        if (jsonObject.containsKey(JConstants.setSloganHidden)) {
            uiConfigBuilder.setSloganHidden(jsonObject.getBooleanValue(JConstants.setSloganHidden));
        }
        //  授权页动画
        if (jsonObject.containsKey(JConstants.setNeedStartAnim)) {
            uiConfigBuilder.setNeedStartAnim(jsonObject.getBooleanValue(JConstants.setNeedStartAnim));
        }
        if (jsonObject.containsKey(JConstants.setNeedCloseAnim)) {
            uiConfigBuilder.setNeedCloseAnim(jsonObject.getBooleanValue(JConstants.setNeedCloseAnim));
        }
        //  授权页弹窗模式 setDialogTheme
        if (jsonObject.containsKey(JConstants.setDialogTheme)) {
            JSONArray jsonArray = jsonObject.getJSONArray(JConstants.setDialogTheme);
            uiConfigBuilder.setDialogTheme(jsonArray.getIntValue(0), jsonArray.getIntValue(1),
                    jsonArray.getIntValue(2), jsonArray.getIntValue(3), jsonArray.getBooleanValue(4));
        }
    }

    private JSONObject convertToResult(boolean enable) {
        JSONObject result = new JSONObject();
        result.put(JConstants.ENABLE, enable);
        return result;
    }

    private JSONObject convertToResult(int code, String content) {
        JSONObject result = new JSONObject();
        result.put(JConstants.CODE, code);
        result.put(JConstants.CONTENT, content);
        return result;
    }

    private JSONObject convertToResult(int code, String content, String operator) {
        JSONObject result = new JSONObject();
        result.put(JConstants.CODE, code);
        result.put(JConstants.CONTENT, content);
        result.put(JConstants.OPERATOR, operator);
        return result;
    }

    @Override
    public void destroy() {

    }
}
