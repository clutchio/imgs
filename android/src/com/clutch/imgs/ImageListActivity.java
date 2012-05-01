package com.clutch.imgs;

import org.json.JSONObject;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;

import com.clutch.ClutchCallback;
import com.clutch.ClutchView;
import com.clutch.ClutchViewMethodDispatcher;

public class ImageListActivity extends Activity {
	
	private class ImageListDispatcher extends ClutchViewMethodDispatcher {
		public void methodCalled(String methodName, JSONObject params, ClutchCallback callback) {
			Log.i("ClutchImageListActivity", methodName + params);
			// You should override this..
		}
	}
	
	public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        ClutchView cv = new ClutchView(this.getApplicationContext());
        ImageListDispatcher dispatcher = new ImageListDispatcher();
        cv.configure("imagetable", dispatcher);
        this.setContentView(cv);
        cv.render();
    }
}
