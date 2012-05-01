package com.clutch.imgs;

import android.app.TabActivity;
import android.content.Intent;
import android.content.res.Resources;
import android.os.Bundle;
import android.widget.TabHost;

import com.clutch.Clutch;

public class Imgs extends TabActivity {
	public void onCreate(Bundle savedInstanceState) {
	    super.onCreate(savedInstanceState);
	    setContentView(R.layout.main);
	    
	    Clutch.setup(this.getApplicationContext(), "b7ec3bbb-3044-4861-a6f4-7523802f6e52");

	    Resources res = getResources(); // Resource object to get Drawables
	    TabHost tabHost = getTabHost();  // The activity TabHost
	    TabHost.TabSpec spec;  // Resusable TabSpec for each tab
	    Intent intent;  // Reusable Intent for each tab

	    // Create an Intent to launch an Activity for the tab (to be reused)
	    intent = new Intent().setClass(this, ImageListActivity.class);

	    // Initialize a TabSpec for each tab and add it to the TabHost
	    spec = tabHost.newTabSpec("hot").setIndicator("Hot",
	                      res.getDrawable(R.drawable.ic_tab_hot))
	                  .setContent(intent);
	    tabHost.addTab(spec);

	    // Do the same for the other tabs
	    intent = new Intent().setClass(this, ImageListActivity.class);
	    spec = tabHost.newTabSpec("new").setIndicator("New",
	                      res.getDrawable(R.drawable.ic_tab_new))
	                  .setContent(intent);
	    tabHost.addTab(spec);
	    
	    intent = new Intent().setClass(this, ImageListActivity.class);
	    spec = tabHost.newTabSpec("top").setIndicator("Top",
	                      res.getDrawable(R.drawable.ic_tab_top))
	                  .setContent(intent);
	    tabHost.addTab(spec);

	    intent = new Intent().setClass(this, MoreActivity.class);
	    spec = tabHost.newTabSpec("more").setIndicator("More",
	                      res.getDrawable(R.drawable.ic_tab_more))
	                  .setContent(intent);
	    tabHost.addTab(spec);

	    tabHost.setCurrentTab(2);
	}
	
	protected void onPause() {
		super.onPause();
		Clutch.onPause();
	}
	
	protected void onResume() {
		super.onResume();
		Clutch.onResume();
	}
}