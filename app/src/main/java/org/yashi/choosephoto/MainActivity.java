package org.yashi.choosephoto;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.ImageFormat;
import android.graphics.Matrix;
import android.graphics.PixelFormat;
import android.graphics.Rect;
import android.graphics.YuvImage;
import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.View;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.ImageButton;
import android.hardware.Camera;
import android.view.Surface;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.WindowManager;
import android.view.Display;

import java.io.ByteArrayOutputStream;
import java.io.Console;
import java.io.IOException;

public class MainActivity extends AppCompatActivity implements SurfaceHolder.Callback{

    private static final String TAG = "ChrisAcvitity";
    private Camera mCamera;
    private SurfaceHolder mHolder;
    private SurfaceView mView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        toolbar.setTitle("百里挑一");
        setSupportActionBar(toolbar);
        mView = (SurfaceView) findViewById(R.id.surfaceView);
        mView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                mCamera.takePicture(null, null , myjpegCallback);
            }
        });
        mHolder = mView.getHolder();
        mHolder.addCallback(this);
    }
    Camera.PictureCallback myjpegCallback = new Camera.PictureCallback() {
        public void onPictureTaken(byte[] data, Camera camera) {
            final Bitmap bitmap = BitmapFactory.decodeByteArray(data
                    , 0, data.length);
            //ImageView show = (ImageView) saveDialog.findViewById(R.id.show);
            //show.setImageBitmap(bitmap);
            camera.stopPreview();
            camera.startPreview();
        }
    };
    // SurfaceHolder.Callback
    public void surfaceCreated(SurfaceHolder holder){
        mCamera = getCameraInstance();
        try {
            mCamera.setPreviewDisplay(holder);
        } catch (IOException e) {
            Snackbar.make(mView, e.getMessage(), Snackbar.LENGTH_INDEFINITE)
                    .setAction("Action", null).show();
        }
        mCamera.setPreviewCallback(null);
        /*
        mCamera.setPreviewCallback(new Camera.PreviewCallback(){
            @Override
            public void onPreviewFrame(byte[] data, Camera camera) {
                Camera.Size size = camera.getParameters().getPreviewSize();
                try{
                    YuvImage image = new YuvImage(data, ImageFormat.NV21, size.width, size.height, null);
                    if(image!=null){
                        ByteArrayOutputStream stream = new ByteArrayOutputStream();
                        image.compressToJpeg(new Rect(0, 0, size.width, size.height), 80, stream);
                        Bitmap bmp = BitmapFactory.decodeByteArray(stream.toByteArray(), 0, stream.size());
                        Matrix matrix = new Matrix();
                        matrix.postRotate(90);
                        Bitmap bitmap = Bitmap.createBitmap(bmp.getWidth(), bmp.getHeight(), Bitmap.Config.ARGB_8888);
                        Bitmap nbmp2 = Bitmap.createBitmap(bmp, 0,0, bmp.getWidth(),  bmp.getHeight(), matrix, true);
                        stream.close();
                    }
                }catch(Exception e){
                    Snackbar.make(mView, e.getMessage(), Snackbar.LENGTH_INDEFINITE)
                            .setAction("Action", null).show();
                }
            }
        });
        */
        mCamera.startPreview();
        mCamera.autoFocus(afcb);
    }
    Camera.AutoFocusCallback afcb=new Camera.AutoFocusCallback() {
        public void onAutoFocus(boolean success, Camera camera) {
            if(success){
                //System.out.println("对焦完成");
            }
        }
    };
    public void surfaceChanged(SurfaceHolder holder, int format, int width, int height){
        refreshCamera();
        int rotation = getDisplayOrientation(); //窗口方向
        mCamera.setDisplayOrientation(rotation); //相机方向
    }
    public void surfaceDestroyed(SurfaceHolder holder){
        System.exit(0); //先直接退出
//        if (mCamera != null)
//        {
//            mHolder.removeCallback(this);
//            mCamera.setPreviewCallback(null);
//            mCamera.stopPreview();
//            mCamera.release();
//            mCamera = null;
//        }
    }

    public static Camera getCameraInstance(){
        Camera c = null;
        try {
            c = Camera.open();
        } catch(Exception e){
            Log.d("TAG", "camera is not available");
            //Snackbar.make(mView, e.getMessage(), Snackbar.LENGTH_INDEFINITE)
            //        .setAction("Action", null).show();
        }
        return c;
    }

    private int getDisplayOrientation(){
        WindowManager windowManager = getWindowManager();
        Display display = windowManager.getDefaultDisplay();
        int rotation = display.getRotation();
        int degrees = 0;
        switch (rotation){
            case Surface.ROTATION_0:
                degrees = 0;
                break;
            case Surface.ROTATION_90:
                degrees = 90;
                break;
            case Surface.ROTATION_180:
                degrees = 180;
                break;
            case Surface.ROTATION_270:
                degrees = 270;
                break;
        }

        android.hardware.Camera.CameraInfo camInfo =
                new android.hardware.Camera.CameraInfo();
        android.hardware.Camera.getCameraInfo(Camera.CameraInfo.CAMERA_FACING_BACK, camInfo);

        // camInfo方向
        int result = (camInfo.orientation - degrees + 360) % 360;

        return result;
    }

    private void refreshCamera(){
        if (mHolder.getSurface() == null){
            // preview surface does not exist
            return;
        }

        // stop preview before making changes
        try {
            mCamera.stopPreview();
        } catch(Exception e){
            Snackbar.make(mView, e.getMessage(), Snackbar.LENGTH_INDEFINITE)
                    .setAction("Action", null).show();
        }

        // set preview size and make any resize, rotate or
        // reformatting changes here
        // start preview with new settings
        try {
            mCamera.setPreviewDisplay(mHolder);
            mCamera.startPreview();
        } catch (Exception e) {
            Snackbar.make(mView, e.getMessage(), Snackbar.LENGTH_INDEFINITE)
                    .setAction("Action", null).show();
        }
    }

    private Camera.PictureCallback jpegCallback = new Camera.PictureCallback(){

        public void onPictureTaken(byte[] data, Camera camera) {
            Camera.Parameters ps = camera.getParameters();

        }
    };

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    @Override
    protected void onPause() {
        super.onPause();

        mCamera.setPreviewCallback(null);
        mCamera.stopPreview();
        mCamera.release();
        mCamera = null;
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (null!=mCamera){
            mCamera = getCameraInstance();
            try {
                mCamera.setPreviewDisplay(mHolder);
                mCamera.startPreview();
            } catch(IOException e) {
                Snackbar.make(mView, e.getMessage(), Snackbar.LENGTH_INDEFINITE)
                        .setAction("Action", null).show();
            }
        }
    }
}
