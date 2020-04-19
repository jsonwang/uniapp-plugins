package com.wangcheng.googlepaylibray;

import android.app.Application;

public class SubApp extends Application {
    private static final SubApp subApp = new SubApp();

    public static SubApp getInstance() {
        return subApp;
    }
}
