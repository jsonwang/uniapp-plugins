package uni.dcloud.io.uniplugin_richalert;

import android.app.Activity;
import android.content.Context;
import android.content.DialogInterface;
import android.graphics.Color;
import android.text.TextUtils;
import android.util.Log;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.android.billingclient.api.BillingClient;
import com.android.billingclient.api.BillingClientStateListener;
import com.android.billingclient.api.BillingFlowParams;
import com.android.billingclient.api.BillingResult;
import com.android.billingclient.api.Purchase;
import com.android.billingclient.api.PurchasesUpdatedListener;
import com.android.billingclient.api.SkuDetails;
import com.android.billingclient.api.SkuDetailsParams;
import com.android.billingclient.api.SkuDetailsResponseListener;
import com.taobao.weex.WXSDKEngine;
import com.taobao.weex.annotation.JSMethod;
import com.taobao.weex.bridge.JSCallback;
import com.taobao.weex.utils.WXLogUtils;
import com.taobao.weex.utils.WXResourceUtils;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


/*
 ##   1.申请一个google play开发者账号，需要支付25美金
##   2.提前准备好一个apk（不需要集成支付sdk，占位用），在google play控制台上传你的apk
##   3.发布一个alpha或者beta的版本，发布之前需要点亮以下选项（提交商品详情内容）（确定内容分级）（选择发布范围）等，之后才能正常发布
##   4.添加测试人员，等应用审核通过之后，会得到一个地址，把地址发给对方，让对方点击同意加入测试即可，测试地址;
	https://play.google.com/apps/testing/xxx    xxx是你应用的包名
##   5.需要创建应用内商品（商品id，商品描述，定价），按提示填就可以了

一定要等你的应用为Published状态之后，在app里面才能查到商品id，执行支付等操作，否则怎么样都查不到

* */


//https://ask.dcloud.net.cn/article/35416
public class GooglePayWXModule extends WXSDKEngine.DestroyableModule implements BillingClientStateListener, PurchasesUpdatedListener, SkuDetailsResponseListener {
    public String CONTENT = "content";
    public String CONTENT_COLOR = "contentColor";
    public String CONTENT_ALIGN = "contentAlign";
    public String POSITION = "position";
    public String BUTTONS = "buttons";
    public String CHECKBOX = "checkBox";
    public String TITLE_ALIGN = "titleAlign";

    //内购的两种类型 消费 的 订阅的
    public String INAPP_TYPE = "INAPP";
    public String SUBS_TYPE = "SUBS";

    public  JSCallback ceateJSCallback = null;
    public  JSCallback payJSCallback = null;

    //默认黑色
    public static int defColor = Color.BLACK;

    RichAlert alert;

    private static final String TAG = "GooglePayUtil";

    private BillingClient billingClient;


    //所有商品 ID 上层初始化时要设置这个值 初始化时一起传入， INAPP 和 SUBS 都有
    private Map<String, List> serviceSKUS = new HashMap<String, List>();


    /**
     * SkuDetails for all known SKUs.
     */

    public Map<String, SkuDetails> skusWithSkuDetails = new HashMap<String, SkuDetails>();


    /*初始化充值*/
    @JSMethod(uiThread = true)
    public void createPayCenter(JSONObject options, JSCallback jsCallback) {
        if (mWXSDKInstance.getContext() instanceof Activity) {

            ceateJSCallback = jsCallback;
            List INAPP_DATA = options.getJSONArray(INAPP_TYPE);
            List SUBS_DATA = options.getJSONArray(SUBS_TYPE);
            serviceSKUS.put(INAPP_TYPE, INAPP_DATA);
            serviceSKUS.put(SUBS_TYPE, SUBS_DATA);

            billingClient = BillingClient.newBuilder(mWXSDKInstance.getContext())
                    .setListener(this)
                    .enablePendingPurchases() // Not used for subscriptions.
                    .build();
            if (!billingClient.isReady()) {
                Log.d(TAG, "BillingClient: Start connection...");
                billingClient.startConnection(this);
            }
        }
    }

    @JSMethod(uiThread = true)
    public void show(JSONObject options, JSCallback jsCallback) {

        if (mWXSDKInstance.getContext() instanceof Activity) {

            String content = options.getString(CONTENT);
            int contentColor = WXResourceUtils.getColor(options.getString(CONTENT_COLOR), defColor);
            String contentAlign = options.getString(CONTENT_ALIGN);

            String title = options.getString(RichAlert.TITLE);
            int titleColor = WXResourceUtils.getColor(options.getString(RichAlert.TITLE_COLOR), defColor);
            String titleAlign = options.getString(TITLE_ALIGN);

            String postion = options.getString(POSITION);

            RichAlert richAlert = new RichAlert(mWXSDKInstance.getContext());

            JSONArray buttons = options.getJSONArray(BUTTONS);
            JSONObject checkBox = options.getJSONObject(CHECKBOX);

            if (!TextUtils.isEmpty(title)) {
                richAlert.setTitle(title, titleColor, titleAlign);
            }
            if (!TextUtils.isEmpty(content)) {
                richAlert.setContent(content, contentColor, contentAlign, jsCallback);
            }
            if (checkBox != null) {
                richAlert.setCheckBox(checkBox, jsCallback);
            }
            if (buttons != null) {
                richAlert.setButtons(buttons, jsCallback);
            }
            if (!TextUtils.isEmpty(postion)) {
                richAlert.setPosition(postion);
            }

//            richAlert.show();
//            tracking(richAlert, jsCallback);
        }
    }

    private void tracking(RichAlert dialog, final JSCallback jsCallback) {
        alert = dialog;
        dialog.setOnCancelListener(new DialogInterface.OnCancelListener() {
            @Override
            public void onCancel(DialogInterface dialog) {
                JSONObject result = new JSONObject();
                result.put("type", "backCancel");
                jsCallback.invoke(result);
            }
        });
        dialog.setOnDismissListener(new DialogInterface.OnDismissListener() {
            @Override
            public void onDismiss(DialogInterface dialog) {
                alert = null;
            }
        });
    }

    @JSMethod(uiThread = true)
    public void dismiss() {
        destroy();
    }

//    @Override
//    public void destroy() {
//        if (alert != null && alert.isShowing()) {
//            WXLogUtils.w("Dismiss the active dialog");
//            alert.dismiss();
//        }
//    }


    //////
    /**
     * 开始购买  SKU
     */
    @JSMethod(uiThread = true)
    public void paySKU(JSONObject options, JSCallback jsCallback) {
        if (mWXSDKInstance.getContext() instanceof Activity) {

            payJSCallback = jsCallback;
            SkuDetails skuDetails = null;
            // Create the parameters for the purchase.
            if (skusWithSkuDetails.size() != 0) {
                skuDetails = skusWithSkuDetails.get(options.getString("SKU"));
            }

            if (skuDetails == null) {
                Log.e("Billing", "Could not find SkuDetails to make purchase.");
                return;
            }

            BillingFlowParams.Builder billingBuilder =
                    BillingFlowParams.newBuilder().setSkuDetails(skuDetails);

            BillingFlowParams billingParams = billingBuilder.build();

            if (!billingClient.isReady()) {
                Log.e(TAG, "launchBillingFlow: BillingClient is not ready");
            }
            BillingResult billingResult = billingClient.launchBillingFlow((Activity) mWXSDKInstance.getContext(), billingParams);
            int responseCode = billingResult.getResponseCode();
            String debugMessage = billingResult.getDebugMessage();
            //TODO 返回 是否成功失败
            Log.d(TAG, "launchBillingFlow: BillingResponse " + responseCode + " " + debugMessage);
        }
    }

    public void paySKU(Activity activity, String sku) {

    }

    /**
     * 销毁时候调用
     */
    public void destroy() {
//        Log.d(TAG, "ON_DESTROY");
        if (billingClient.isReady()) {
//            Log.d(TAG, "BillingClient can only be used once -- closing connection");
            // BillingClient can only be used once.
            // After calling endConnection(), we must create a new BillingClient.
            billingClient.endConnection();
        }
    }

    /**
     * @param billingResult BillingClient 初始化成功时候的回调
     */
    @Override
    public void onBillingSetupFinished(BillingResult billingResult) {
        int responseCode = billingResult.getResponseCode();
        String debugMessage = billingResult.getDebugMessage();
//        Log.d(TAG, "onBillingSetupFinished: " + responseCode + " " + debugMessage);
        if (responseCode == BillingClient.BillingResponseCode.OK) {
            //TODO 你看看 这个地方需不需要给他们一些回调
            // The billing client is ready. You can query purchases here.
            querySkuDetails();
            queryPurchases();
        }
    }

    @Override
    public void onBillingServiceDisconnected() {
        // TODO: Try connecting again with exponential backoff.
        //链接不成功时候，是否需要重连
    }

    //支付结果
    @Override
    public void onPurchasesUpdated(BillingResult billingResult, List<Purchase> list) {
        if (billingResult == null) {
            Log.wtf(TAG, "onPurchasesUpdated: null BillingResult");
            return;
        }
        int responseCode = billingResult.getResponseCode();
        String debugMessage = billingResult.getDebugMessage();
        Log.d(TAG, "onPurchasesUpdated: $responseCode $debugMessage");


        //订单信息要发给服务器进行二次验证等后面工作
//        PurchaseHistoryBean purchaseHistory = new PurchaseHistoryBean();
//        purchaseHistory.uid = NumberParserUtil.parseLong(UserInfoManager.create().getUserId(), -1);
//        purchaseHistory.orderId = purchase.getOrderId();
//        purchaseHistory.purchaseToken = purchase.getPurchaseToken();
//        purchaseHistory.developerPayload = purchase.getDeveloperPayload();
//        purchaseHistory.productId = purchase.getSku();
//        purchaseHistory.purchaseTime = purchase.getPurchaseTime();


        if (payJSCallback !=null)
        {
            //通知 JS 购买成功
            JSONObject result = new JSONObject();
            result.put("code", "1");
            payJSCallback.invoke(result);
        }

        switch (responseCode) {
            case BillingClient.BillingResponseCode.OK:
                if (list == null) {
                    Log.d(TAG, "onPurchasesUpdated: null purchase list");
                    processPurchases(null);
                } else {
                    processPurchases(list);
                }
                break;
            case BillingClient.BillingResponseCode.USER_CANCELED:
                Log.i(TAG, "onPurchasesUpdated: User canceled the purchase");
                break;
            case BillingClient.BillingResponseCode.ITEM_ALREADY_OWNED:
                Log.i(TAG, "onPurchasesUpdated: The user already owns this item");
                break;
            case BillingClient.BillingResponseCode.DEVELOPER_ERROR:
                Log.e(TAG, "onPurchasesUpdated: Developer error means that Google Play " +
                        "does not recognize the configuration. If you are just getting started, " +
                        "make sure you have configured the application correctly in the " +
                        "Google Play Console. The SKU product ID must match and the APK you " +
                        "are using must be signed with release keys."
                );
                break;
        }
    }

    //查询商品返回
    @Override
    public void onSkuDetailsResponse(BillingResult billingResult, List<SkuDetails> list) {
        if (billingResult == null) {
            Log.wtf(TAG, "onSkuDetailsResponse: null BillingResult");
            return;
        }

        int responseCode = billingResult.getResponseCode();
        String debugMessage = billingResult.getDebugMessage();
        switch (responseCode) {
            case BillingClient.BillingResponseCode.OK:
                Log.i(TAG, "onSkuDetailsResponse : 商品个数为：" + list.size() + "状态为：" + responseCode + " " + debugMessage);
                if (list == null) {
                    Log.w(TAG, "onSkuDetailsResponse 2222: null SkuDetails list");

                    //通知 JS 初始化成功
                    JSONObject result = new JSONObject();
                    result.put("code", "-1");
                    ceateJSCallback.invoke(result);

                } else {
                    Map<String, SkuDetails> newSkusDetailList = new HashMap<String, SkuDetails>();
                    for (SkuDetails skuDetails : list) {
                        skusWithSkuDetails.put(skuDetails.getSku(), skuDetails);
                    }
//                    skusWithSkuDetails.postValue(newSkusDetailList);
                    Log.i(TAG, "onSkuDetailsResponse333: count " + list.size());

                    //判断所有商品是否全部取完
                    if (serviceSKUS.get(INAPP_TYPE).size() + serviceSKUS.get(SUBS_TYPE).size() == skusWithSkuDetails.size()) {
                        Log.i(TAG, "所有商品全部取完" + skusWithSkuDetails.size());

                        if (ceateJSCallback !=null) {
                            //通知 JS 初始化成功
                            JSONObject result = new JSONObject();
                            result.put("code", "1");
                            ceateJSCallback.invoke(result);
                        }

                    }

                }
                break;
            case BillingClient.BillingResponseCode.SERVICE_DISCONNECTED:
            case BillingClient.BillingResponseCode.SERVICE_UNAVAILABLE:
            case BillingClient.BillingResponseCode.BILLING_UNAVAILABLE:
            case BillingClient.BillingResponseCode.ITEM_UNAVAILABLE:
            case BillingClient.BillingResponseCode.DEVELOPER_ERROR:
            case BillingClient.BillingResponseCode.ERROR:
                Log.e(TAG, "onSkuDetailsResponse " + responseCode + " " + debugMessage);
                break;
            case BillingClient.BillingResponseCode.USER_CANCELED:
                Log.i(TAG, "onSkuDetailsResponse " + responseCode + " " + debugMessage);
                break;
            // These response codes are not expected.
            case BillingClient.BillingResponseCode.FEATURE_NOT_SUPPORTED:
            case BillingClient.BillingResponseCode.ITEM_ALREADY_OWNED:
            case BillingClient.BillingResponseCode.ITEM_NOT_OWNED:
            default:
                Log.wtf(TAG, "onSkuDetailsResponse ak: " + responseCode + " " + debugMessage);
        }

    }

    /**
     * 查询所有商品信息
     * In order to make purchases, you need the {@link SkuDetails} for the item or subscription.
     * This is an asynchronous call that will receive a result in {@link #onSkuDetailsResponse}.
     */
    public void querySkuDetails() {
        Log.d(TAG, "querySkuDetails");

        //消耗类型
        SkuDetailsParams inapp_params = SkuDetailsParams.newBuilder()
                .setType(BillingClient.SkuType.INAPP)
                .setSkusList(serviceSKUS.get(INAPP_TYPE))
                .build();
        Log.i(TAG, "querySkuDetailsAsync");
        billingClient.querySkuDetailsAsync(inapp_params, this);

        //订阅类型
        SkuDetailsParams subs_params = SkuDetailsParams.newBuilder()
                .setType(BillingClient.SkuType.SUBS)
                .setSkusList(serviceSKUS.get(SUBS_TYPE))
                .build();
        Log.i(TAG, "querySkuDetailsAsync");
        billingClient.querySkuDetailsAsync(subs_params, this);
    }

    /**
     * Query Google Play Billing for existing purchases. 查询商品信息
     * <p>
     * New purchases will be provided to the PurchasesUpdatedListener.
     * You still need to check the Google Play Billing API to know when purchase tokens are removed.
     */
    public void queryPurchases() {
        if (!billingClient.isReady()) {
            Log.e(TAG, "queryPurchases: BillingClient is not ready");
        }
        Log.d(TAG, "queryPurchases: SUBS");
        Purchase.PurchasesResult result = billingClient.queryPurchases(BillingClient.SkuType.SUBS);
        if (result == null) {
            Log.i(TAG, "queryPurchases: null purchase result");
            processPurchases(null);
        } else {
            if (result.getPurchasesList() == null) {
                Log.i(TAG, "queryPurchases: null purchase list");
                processPurchases(null);
            } else {
                processPurchases(result.getPurchasesList());
            }
        }
    }

    /**
     * Send purchase SingleLiveEvent and update purchases LiveData.
     * <p>
     * The SingleLiveEvent will trigger network call to verify the subscriptions on the sever.
     * The LiveData will allow Google Play settings UI to update based on the latest purchase data.
     */
    private void processPurchases(List<Purchase> purchasesList) {
        if (purchasesList != null) {
            Log.d(TAG, "processPurchases: " + purchasesList.size() + " purchase(s)");
        } else {
            Log.d(TAG, "processPurchases: with no purchases");
        }
        if (isUnchangedPurchaseList(purchasesList)) {
            Log.d(TAG, "processPurchases: Purchase list has not changed");
            return;
        }
//        purchaseUpdateEvent.postValue(purchasesList);
//        purchases.postValue(purchasesList);
        if (purchasesList != null) {
            logAcknowledgementStatus(purchasesList);
        }
    }

    /**
     * Check whether the purchases have changed before posting changes.
     */
    private boolean isUnchangedPurchaseList(List<Purchase> purchasesList) {
        // TODO: Optimize to avoid updates with identical data.
        return false;
    }

    /**
     * Log the number of purchases that are acknowledge and not acknowledged.
     * <p>
     * https://developer.android.com/google/play/billing/billing_library_releases_notes#2_0_acknowledge
     * <p>
     * When the purchase is first received, it will not be acknowledge.
     * This application sends the purchase token to the server for registration. After the
     * purchase token is registered to an account, the Android app acknowledges the purchase token.
     * The next time the purchase list is updated, it will contain acknowledged purchases.
     */
    private void logAcknowledgementStatus(List<Purchase> purchasesList) {
        int ack_yes = 0;
        int ack_no = 0;
        for (Purchase purchase : purchasesList) {
            if (purchase.isAcknowledged()) {
                ack_yes++;
            } else {
                ack_no++;
            }
        }
        Log.d(TAG, "logAcknowledgementStatus: acknowledged=" + ack_yes +
                " unacknowledged=" + ack_no);
    }


}
