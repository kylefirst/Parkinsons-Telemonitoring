package com.example.kk.mobilevoicediagnostic;

import android.content.Intent;
import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Spinner;
import android.widget.Toast;

import static android.provider.AlarmClock.EXTRA_MESSAGE;

public class SettingsNewActivity extends AppCompatActivity {

    EditText phoneField;
    EditText medField;
    Button phoneButton;
    Button medButton;
    private String phoneNumber;
    private String medications;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_settings_new);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        Spinner spinner = (Spinner) findViewById(R.id.quantSpinner);
// Create an ArrayAdapter using the string array and a default spinner layout
        ArrayAdapter<CharSequence> adapter = ArrayAdapter.createFromResource(this,
                R.array.quantArray, android.R.layout.simple_spinner_item);
// Specify the layout to use when the list of choices appears
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
// Apply the adapter to the spinner
        spinner.setAdapter(adapter);

        Spinner timeSpinner = (Spinner) findViewById(R.id.timeSpinner);
// Create an ArrayAdapter using the string array and a default spinner layout
        ArrayAdapter<CharSequence> timeAdapter = ArrayAdapter.createFromResource(this,
                R.array.timeArray, android.R.layout.simple_spinner_item);
// Specify the layout to use when the list of choices appears
        timeAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
// Apply the adapter to the spinner
        timeSpinner.setAdapter(timeAdapter);

        getSupportActionBar().setDisplayHomeAsUpEnabled(true);

        phoneField = (EditText)findViewById(R.id.phoneField);
        medField = (EditText)findViewById(R.id.medField);
        phoneButton = (Button)findViewById(R.id.phoneSubmitButton);
        medButton = (Button)findViewById(R.id.medSubmitButton);

        phoneButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                phoneNumber = phoneField.getText().toString();

                Toast.makeText(SettingsNewActivity.this, "Phone Set",
                        Toast.LENGTH_LONG).show();
            }
        });

        medButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                medications = medField.getText().toString();

                Toast.makeText(SettingsNewActivity.this, "Medication Set",
                        Toast.LENGTH_LONG).show();
            }
        });
    }

    @Override
    protected void onPause() {
        super.onPause();
        Intent intent = new Intent(this, MainActivity.class);
        intent.putExtra(Intent.EXTRA_PHONE_NUMBER, phoneNumber);
        intent.putExtra(EXTRA_MESSAGE, medications);
        startActivity(intent);
    }
}
