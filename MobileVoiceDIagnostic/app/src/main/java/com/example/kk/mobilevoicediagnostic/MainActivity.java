package com.example.kk.mobilevoicediagnostic;

import android.media.MediaPlayer;
import android.media.MediaRecorder;

import android.net.Uri;
import android.os.Environment;
import android.support.annotation.NonNull;
import android.support.v7.app.AppCompatActivity;

import android.os.Bundle;
import android.view.View;

import android.widget.Button;
import android.widget.Toast;

import java.io.File;
import java.io.IOException;
import java.util.Random;

import static android.Manifest.permission.RECORD_AUDIO;
import static android.Manifest.permission.WRITE_EXTERNAL_STORAGE;

import android.support.v4.app.ActivityCompat;
import android.content.pm.PackageManager;
import android.support.v4.content.ContextCompat;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.storage.FirebaseStorage;
import com.google.firebase.storage.StorageReference;
import com.google.firebase.storage.UploadTask;

public class MainActivity extends AppCompatActivity {

    Button buttonStartStop, buttonPlayStopLastRecordAudio,
            buttonReset, buttonUpload;
    String AudioSavePathInDevice = null;
    MediaRecorder mediaRecorder ;
    public static final int RequestPermissionCode = 1;
    private StorageReference mStorageRef;
    MediaPlayer mediaPlayer ;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        buttonStartStop = (Button) findViewById(R.id.button);
        buttonPlayStopLastRecordAudio = (Button) findViewById(R.id.button2);
        buttonReset = (Button)findViewById(R.id.button3);
        buttonUpload = (Button)findViewById(R.id.button4);

        buttonPlayStopLastRecordAudio.setEnabled(false);
        buttonReset.setEnabled(false);
        buttonUpload.setEnabled(false);

        mStorageRef = FirebaseStorage.getInstance().getReference();

        buttonStartStop.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {

                if(checkPermission()) {
                    if(buttonStartStop.getText().equals("RECORD")) {
                        AudioSavePathInDevice =
                                Environment.getExternalStorageDirectory().getAbsolutePath() + "/"
                                        + "AudioRecording.wav";

                        MediaRecorderReady();

                        try {
                            mediaRecorder.prepare();
                            mediaRecorder.start();
                        } catch (IllegalStateException e) {
                            // TODO Auto-generated catch block
                            e.printStackTrace();
                        } catch (IOException e) {
                            // TODO Auto-generated catch block
                            e.printStackTrace();
                        }

                        buttonStartStop.setText("STOP");
                        buttonPlayStopLastRecordAudio.setEnabled(false);

                        Toast.makeText(MainActivity.this, "Recording started",
                                Toast.LENGTH_LONG).show();
                    }
                    else if(buttonStartStop.getText().equals("STOP")) {
                        mediaRecorder.stop();
                        buttonStartStop.setText("RECORD");
                        buttonPlayStopLastRecordAudio.setEnabled(true);
                        buttonStartStop.setEnabled(true);
                        buttonReset.setEnabled(true);
                        buttonUpload.setEnabled(true);
                        buttonPlayStopLastRecordAudio.setEnabled(true);

                        Toast.makeText(MainActivity.this, "Recording Completed",
                                Toast.LENGTH_LONG).show();
                    }
                } else {
                    requestPermission();
                }

            }
        });

        buttonPlayStopLastRecordAudio.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) throws IllegalArgumentException,
                    SecurityException, IllegalStateException {

                if(buttonPlayStopLastRecordAudio.getText().equals("PLAY")) {
                    buttonStartStop.setEnabled(false);

                    mediaPlayer = new MediaPlayer();
                    try {
                        mediaPlayer.setDataSource(AudioSavePathInDevice);
                        mediaPlayer.prepare();
                    } catch (IOException e) {
                        e.printStackTrace();
                    }

                    mediaPlayer.start();
                    buttonPlayStopLastRecordAudio.setText("STOP PLAYING RECORDING");
                    Toast.makeText(MainActivity.this, "Recording Playing",
                            Toast.LENGTH_LONG).show();
                }
                else if(buttonPlayStopLastRecordAudio.getText().equals("STOP PLAYING RECORDING")) {
                    buttonStartStop.setEnabled(true);
                    buttonPlayStopLastRecordAudio.setText("PLAY");

                    if(mediaPlayer != null){
                        mediaPlayer.stop();
                        mediaPlayer.release();
                        MediaRecorderReady();
                    }
                }
            }
        });

        buttonReset.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                buttonPlayStopLastRecordAudio.setEnabled(false);
                buttonStartStop.setEnabled(true);
                buttonReset.setEnabled(false);
                buttonUpload.setEnabled(false);

                mediaRecorder.reset();
            }
        });

        buttonUpload.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                buttonUpload.setEnabled(false);

                System.out.println("Environment.getExternalStorageDirectory().getAbsolutePath()\n" +
                        "                        + \"/\" + \"AudioRecording.wav\"");

                Uri file = Uri.fromFile(new File(Environment.getExternalStorageDirectory().getAbsolutePath()
                        + "/" + "AudioRecording.wav"));
                StorageReference audioFileRef = mStorageRef.child("AudioRecording.wav");

                audioFileRef.putFile(file)
                        .addOnSuccessListener(new OnSuccessListener<UploadTask.TaskSnapshot>() {
                            @Override
                            public void onSuccess(UploadTask.TaskSnapshot taskSnapshot) {
                                // Get a URL to the uploaded content
                                //Uri downloadUrl = taskSnapshot.getDownloadUrl();

                                Toast.makeText(MainActivity.this, "Upload Success!",
                                        Toast.LENGTH_LONG).show();
                            }
                        })
                        .addOnFailureListener(new OnFailureListener() {
                            @Override
                            public void onFailure(@NonNull Exception exception) {
                                // Handle unsuccessful uploads
                                // ...
                            }
                        });
            }
        });

    }

    public void MediaRecorderReady(){
        mediaRecorder=new MediaRecorder();
        mediaRecorder.setAudioSource(MediaRecorder.AudioSource.MIC);
        mediaRecorder.setOutputFormat(MediaRecorder.OutputFormat.THREE_GPP);
        mediaRecorder.setAudioEncoder(MediaRecorder.OutputFormat.AMR_NB);
        mediaRecorder.setOutputFile(AudioSavePathInDevice);
    }

    private void requestPermission() {
        ActivityCompat.requestPermissions(MainActivity.this, new
                String[]{WRITE_EXTERNAL_STORAGE, RECORD_AUDIO}, RequestPermissionCode);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode,
                                           String permissions[], int[] grantResults) {
        switch (requestCode) {
            case RequestPermissionCode:
                if (grantResults.length> 0) {
                    boolean StoragePermission = grantResults[0] ==
                            PackageManager.PERMISSION_GRANTED;
                    boolean RecordPermission = grantResults[1] ==
                            PackageManager.PERMISSION_GRANTED;

                    if (StoragePermission && RecordPermission) {
                        Toast.makeText(MainActivity.this, "Permission Granted",
                                Toast.LENGTH_LONG).show();
                    } else {
                        Toast.makeText(MainActivity.this, "Permission Denied",
                                Toast.LENGTH_LONG).show();
                    }
                }
                break;
        }
    }

    public boolean checkPermission() {
        int result = ContextCompat.checkSelfPermission(getApplicationContext(),
                WRITE_EXTERNAL_STORAGE);
        int result1 = ContextCompat.checkSelfPermission(getApplicationContext(),
                RECORD_AUDIO);
        return result == PackageManager.PERMISSION_GRANTED &&
                result1 == PackageManager.PERMISSION_GRANTED;
    }
}