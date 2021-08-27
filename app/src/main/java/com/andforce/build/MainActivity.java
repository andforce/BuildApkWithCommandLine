package com.andforce.build;

import android.app.Activity;
import android.content.res.Resources;
import android.os.Bundle;
import android.widget.TextView;


public class MainActivity extends Activity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        this.getResources();
        int value = Resources.getSystem().getIdentifier("status_bar_height", "dimen", "android");
        int dimensionPixelSize = getResources().getDimensionPixelSize(value);
        TextView textView = (TextView) findViewById(R.id.first_tv);
        String text = "@*android:status_bar_height, pixelSize: " + dimensionPixelSize;
        textView.setText(text);
    }
}
