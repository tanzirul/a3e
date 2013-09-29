/* Copyright (c) 2011-2013,
 *  Jinseong Jeon <jsjeon@cs.umd.edu>
 *  Tanzirul Azim <mazim002@cs.ucr.edu>
 *  Jeff Foster   <jfoster@cs.umd.edu>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * 3. The names of the contributors may not be used to endorse or promote
 * products derived from this software without specific prior written
 * permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

package umd.troyd;

import com.jayway.android.robotium.solo.Solo;

import android.app.Activity;
import android.app.Instrumentation;
import android.app.KeyguardManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.GridView;
import android.widget.ListView;
import android.widget.ScrollView;
import android.widget.TextView;

public class Troy extends Instrumentation {

	final static String tag = Troy.class.getPackage().getName();

	// App Under Test
	Intent aut = null;
	String actName = null;

	@Override
	public void onCreate(Bundle arg) {
		super.onCreate(arg);
		actName = arg.getString("AUT");
		aut = new Intent();
		aut.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		try {
			aut.setClass(getTargetContext(), Class.forName(actName));
			start();
		} catch (ClassNotFoundException e) {
			Log.e(tag, e.toString());
		}
	}

	static Solo solo;
	static Troy tempClass;
	static Activity act;
	@Override
	public void onStart() {
		super.onStart();
		act = startActivitySync(aut);
		tempClass=this;
		solo = new Solo(this, act);
		solo.getCurrentActivity(); // to collect all opened activities
		getContext().registerReceiver(r, new IntentFilter(Intent.ACTION_RUN));
		KeyguardManager km = (KeyguardManager)
				getContext().getSystemService(Context.KEYGUARD_SERVICE);
		km.newKeyguardLock(tag).disableKeyguard();
		// sync with this i-level logcat
		// before sending an intent to the server, erase the logcat
		// `adb logcat -c`
		// after sending the intent, filter out other messages
		// `adb logcat -d umd.redexer:I *:S`
		Log.i(tag, actName);
		// looping
		while(true) {
			try {
				Thread.sleep(20742);
			} catch (InterruptedException e) {
				Log.e(tag, e.toString());
			}
		}
		// if this finished, broadcast receiver will start on a new process
		// that is, static var. solo, the ultimate controller, would be lost
	}

	@Override
	public void onDestroy() {
		getContext().unregisterReceiver(r);
	}

	enum Command {
		getViews, getActivities, back, down, up, menu,
		edit, // -e idx <EditText idx> -e what <text>
		clear, search, checked, click, clickLong, // -e what <text>
		clickOn,   // -e at x.y
		clickIdx,  // -e idx <TextView idx in the ListView>
		clickImg,  // -e idx <ImageView and ImageButton idx>
		clickItem, // -e idx <Spinner idx> -e item <item idx>
		clickImgView,
		clickImgBtn,
		clickTxtView,
		getTxtViewCount,
		getListViewCount,
		getImgBtnCnt,
		getImgViewCnt,
		drag, // -e from x.y -e to x.y
		// progess (SeekBar and RatingBar) // -e idx <bar idx> -e amount <...>
		// date // -e idx <DatePicker idx> -e date mm/dd/yy
		// time // -e idx <TimePicker idx> -e time hh:mm
		finish
	};

	// to control instrumentation, send an intent to this broadcast receiver
	// `adb shell am broadcast -a android.intent.action.RUN -e cmd <cmd>`
	private BroadcastReceiver r = new BroadcastReceiver() {

		class Coordinates {
			public float x;
			public float y;

			Coordinates(String x, String y) {
				this.x = Float.parseFloat(x);
				this.y = Float.parseFloat(y);
			}
		}

		private String getWhat(Intent intent) {
			return intent.getExtras().getString("what");
		}

		private int getIdx(Intent intent) {
			return Integer.parseInt(intent.getExtras().getString("idx"));
		}

		private int getItem(Intent intent) {
			return Integer.parseInt(intent.getExtras().getString("item"));
		}

		private Coordinates getCoordinate(Intent intent, String key) {
			String x_y = intent.getExtras().getString(key);
			String[] xy = x_y.split("\\.",2);
			return new Coordinates(xy[0],xy[1]);
		}

		@Override
		public void onReceive(Context context, final Intent intent) {
			final String cmd = intent.getExtras().getString("cmd");
			// Any features of Instrumentation should not be on the main thread
			new Thread(new Runnable() {
				public void run() {
					switch(Command.valueOf(cmd)) {
					case getViews: getViews(); break;
					//tanzir
					case clickImgView: 
						int idx = getIdx(intent);
						clickImgView(idx);
						break;
					case clickImgBtn:
						idx = getIdx(intent);
						clickImgBtn(idx);
						break;
					case clickTxtView:
						clickTxtView(intent.getExtras().getString("idx"));
					case getTxtViewCount:
						idx=getIdx(intent);
						//get text view count in idx_th list view
						getTxtViewCount(idx);
						break;
					case getListViewCount:
						getListViewCount();
						break;
					case getImgBtnCnt:
						getImgBtnCount();
					break;
					case getImgViewCnt:
						getImgViewCount();
					break;
					case getActivities: getActivities(); break;
					case back: back(); break;
					case down: down(); break;
					case up  : up();   break;
					case menu: menu(); break;
					case edit:
						idx = getIdx(intent);
						String what = getWhat(intent);
						edit(idx, what);
						break;
					case clear:
					case search:
					case checked:
						what = getWhat(intent);
						if (Command.valueOf(cmd) == Command.clear)
							clear(what);
						else if (Command.valueOf(cmd) == Command.search)
							search(what);
						else
							checked(what);
						break;
					case click:
					case clickLong:
						what = getWhat(intent);
						if (Command.valueOf(cmd) == Command.click)
							click(what, false);
						else
							click(what, true);
						break;
					case clickOn:
						Coordinates pos = getCoordinate(intent, "at");
						clickOn(pos.x, pos.y);
						break;
					case clickIdx:
					case clickImg:
						idx = getIdx(intent);
						if (Command.valueOf(cmd) == Command.clickIdx)
							clickIdx(idx);
						else
							clickImg(idx);
						break;
					case clickItem:
						idx = getIdx(intent);
						int item = getItem(intent);
						clickItem(idx, item);
						break;
					case drag:
						Coordinates pos1 = getCoordinate(intent, "from");
						Coordinates pos2 = getCoordinate(intent, "to");
						drag(pos1.x, pos2.x, pos1.y, pos2.y);
						break;
					case finish:
						tearDown();
						break;
					}
					//Activity act = startActivitySync(aut);
					//reinitializing
					solo = new Solo(tempClass, solo.getCurrentActivity());
					//solo.
					//solo = new Solo(getInstrumentation);
					 // to collect all opened activities
					//solo.getc
				}
			}).start();
		}
	};

	// obtain current objects on the screen
	private void getViews() {
		solo = new Solo(new Troy(), solo.getCurrentActivity());
		for (View v : solo.getCurrentViews()) {
			if(v.isShown()){
				if (v instanceof TextView) {
					String ty = v.getClass().getName();
					Log.d(tag, ty + "<:>" + ((TextView)v).getText());
				} else {
					Log.d(tag, v.toString());
				}
			}
		}
//		for (View v : solo.getCurrentTextViews(solo.getCurrentListViews().get(2))) {
//			if (v instanceof TextView) {
//				String ty = v.getClass().getName();
//				Log.d(tag, ty + "<:>" + ((TextView)v).getText()+"size: "+solo.getCurrentListViews().size());
//			} else {
//				Log.d(tag, v.toString());
//			}
//		}
		//solo.getCurrentTextViews(solo.getCurrentViews(ListView.class).get(0))
	}

	// obtain activities opened so far
	private void getActivities() {
		for (Activity act : solo.getAllOpenedActivities()) {
			Log.d(tag, "opened: " + act.getClass().getName());
			solo = new Solo(tempClass, solo.getCurrentActivity());
		}
	}

	// press BACK
	private void back() {
		solo.goBack();
		Log.d(tag, "back");
	}

	private boolean scrollable() {
		for (View v : solo.getCurrentViews()) {
			if (v instanceof ListView) {
				return true;
			} else if (v instanceof GridView) {
				return true;
			} else if (v instanceof ScrollView) {
				return true;
			}
		}
		return false;
	}

	private boolean checkScrollable() {
		boolean scrollable = scrollable();
		if (!scrollable) {
			Log.d(tag, "not scrollable");
		}
		return scrollable;
	}

	// scroll DOWN
	private void down() {
		if (!checkScrollable()) return;
		solo.scrollDown();
		Log.d(tag, "down");
	}

	// scroll UP
	private void up() {
		if (!checkScrollable()) return;
		solo.scrollUp();
		Log.d(tag, "up");
	}

	// press MENU
	private void menu() {
		solo.sendKey(Solo.MENU);
		Log.d(tag, "menu");
	}

	// edit EditText
	private void edit(int idx, String target) {
		solo.enterText(idx, target);
		Log.d(tag, "edit: " + target + " at " + idx + "th EditText");
	}

	// clear EditText
	private void clear(String target) {
		solo.clearEditText(solo.getEditText(target));
		Log.d(tag, "clear: " + target);
	}

	// search
	private void search(String target) {
		boolean found = solo.searchText(target); 
		Log.d(tag, "search: " + target + ": " + found);
	}

	// checked? // CheckBox, RadioButton, Spinner, ToggleButton
	private void checked(String target) {
		boolean chk = solo.isCheckBoxChecked(target)
				|| solo.isRadioButtonChecked(target)
				|| solo.isSpinnerTextSelected(target)
				|| solo.isTextChecked(target)
				|| solo.isToggleButtonChecked(target);
		Log.d(tag, "checked: " + target + ": " + chk);
	}

	// TextView, Button
	// MenuItem, RadioButton, CheckBox, ToggleButton, CheckedTextView, CompoundButton
	private void click(String target, boolean isLong) {
		if (solo.searchButton(target)) {
			if (isLong) {
				Log.e(tag, "button cannot be clicked long: " + target);
			} else {
				solo.clickOnButton(target);
				Log.d(tag, "click: button: " + target);
			}
		}
		// order matters! many widgets inherit from TextView.
		else if (solo.searchText(target)) {
			if (isLong) {
				solo.clickLongOnText(target);
				Log.d(tag, "clickLong: text: " + target);
			}
			else {
				solo.clickOnText(target);
				Log.d(tag, "click: text: " + target);
			}
		} else {
			Log.d(tag, "not yet clickable: " + target);
		}
	}

	// clicks on a given coordinate on the screen
	private void clickOn(float x, float y) {
		solo.clickOnScreen(x, y);
		Log.d(tag, "clickOn: <" + x + "," + y + ">");
	}

	// TextView in the ListView
	private void clickIdx(int idx) {
		solo.clickInList(idx);
		Log.d(tag, "clickIdx: " + idx);
	}

	// ImageView, ImageButton
	private void clickImg(int idx) {
		solo.clickOnImage(idx);
		Log.d(tag, "click: " + idx + "th image");
	}
	
	//tanzir image view
	private void clickImgView(int idx){
		try{
			if(solo.getCurrentImageViews().size()>idx && solo.getCurrentImageViews().size()>=1)
				solo.clickOnImage(idx);
		}catch(Exception ex)
		{
			System.out.println("A3E image view does not exists");
		}
		
		Log.d(tag, "click: " + idx + "th image view");
	}
	
	//tanzir image button
	private void clickImgBtn(int idx){
		try{
			
				if(solo.getCurrentImageButtons().size()>idx&&solo.getCurrentImageButtons().size()>=1)
					solo.clickOnImageButton(idx);
		}catch(Exception ex)
		{
			System.out.println("A3E image does not exists");
		}
		Log.d(tag, "click: " + idx + "th image button");
	}
	
	//text view
	private void clickTxtView(String idx){
		if(solo.searchText(idx))
			solo.clickOnText(idx);
	}
	//tanzir
	private void getImgViewCount()
	{
		Log.d(tag, "ImageViewCount:" + Integer.toString(solo.getCurrentImageViews().size()));
		//return solo.getCurrentImageViews().size();
	}
	//tanzir
	private void getImgBtnCount()
	{
		
		Log.d(tag, "ImageButtonCount:" + Integer.toString(solo.getCurrentImageButtons().size()));
		//return solo.getCurrentImageButtons().size();
	}
	private void getListViewCount()
	{
		Log.d(tag, "ListViewCount" + Integer.toString(solo.getCurrentListViews().size()));
		//return solo.getCurrentListViews().size();
	}
	
	//less than one
	private void getTxtViewCount(int listViewNo)
	{
		if(listViewNo <= solo.getCurrentListViews().size())
		{
			int c=solo.getCurrentTextViews(solo.getCurrentListViews().get(listViewNo)).size();
			Log.d(tag, Integer.toString(c));
			//return c;
		}
		else Log.d(tag, Integer.toString(-1));
	}
	
	// Spinner
	private void clickItem(int idx, int item) {
		solo.pressSpinnerItem(idx, item);
		Log.d(tag, "clickItem: " + item + "th item of " + idx + "th spinner");
	}

	// touching a given location and dragging it to a new one
	private void drag(float x1, float x2, float y1, float y2) {
		final int step = 2;
		final int stepCntX = Math.round(Math.abs(x1-x2)) / step;
		final int stepCntY = Math.round(Math.abs(y1-y2)) / step;
		final int stepCnt = stepCntX > stepCntY ? stepCntX : stepCntY;
		//tanzir for faster rag
		solo.drag(x1, x2, y1, y2, 10);
		Log.d(tag, "drag: <"+x1+","+y1+"> to <"+x2+","+y2+"> w/ "+stepCnt+" steps");
	}

	// stop the app under test
	private void tearDown() {
		Log.d(tag, "finish");
		finish(0, new Bundle());
	}
}
