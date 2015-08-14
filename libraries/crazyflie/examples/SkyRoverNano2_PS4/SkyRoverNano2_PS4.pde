/**
 Basic demonstration of using a gamepad.
 
 When this sketch runs it will try and find
 a game device that matches the configuration
 file 'gamepad' if it can't match this device
 then it will present you with a list of devices
 you might try and use.
 
 The chosen device requires 3 sliders and 2 button.
 */
import se.bitcraze.crazyflie.lib.toc.*;
import org.gamecontrolplus.gui.*;
import org.gamecontrolplus.*;
import net.java.games.input.*;




CrazyflieWrapper mSky;


ControlIO control;
Configuration config;
ControlDevice gpad;


float LeftPad_PosX;
float LeftPad_PosY;

float RightPad_PosX;
float RightPad_PosY;

float eyeRad   = 80;
float eyeSize  = eyeRad * 2;
float browSize =  eyeSize * 1.2f, browFactor;
float irisRad = 42, irisSize = irisRad * 2;

float roll = 0;
float pitch = 0;
float yaw = 0;
float thrust = 0;


float pad_roll = 0;
float pad_pitch = 0;
float pad_yaw = 0;
float pad_thrust = 0;

int cmd_timer;



public void setup() 
{
 
  size(400, 240);
  // Initialise the ControlIO
  control = ControlIO.getInstance(this);
  // Find a device that matches the configuration file
    
  gpad = control.getMatchedDevice("skyrover");
  if (gpad == null) 
  {
    println("No suitable device configured");
    System.exit(-1); // End the program NOW!
  }


  mSky = new CrazyflieWrapper(); 
}

public void draw() 
{
  background(255, 200, 255);
  
  textSize(14);
  text("Start : c ", 5, 15);
  
  if( mSky.isConnected() )
    text("Status : Connected", 5, 15*2);
  else
    text("Status : Disconnected", 5, 15*2);
  
  
  pad_roll  = gpad.getSlider("ROLL").getValue();
  pad_pitch = gpad.getSlider("PITCH").getValue();
  pad_yaw   = gpad.getSlider("YAW").getValue();
  pad_thrust= gpad.getSlider("THRUST").getValue();
  
  
  //-- Send Command
  //  
  if( (millis()-cmd_timer) >= 50 )
  {
    cmd_timer = millis();
    
    if( mSky.isConnected() )
    {
      //-- roll
      roll = pad_roll * 30;
      
      //-- pitch
      pitch = -pad_pitch * 30;

      //-- yaw
      yaw = pad_yaw * 200;

      
      //-- thrust 
      thrust = - pad_thrust * 60000;
      if( thrust < 0 ) thrust = 0;
      
      mSky.sendCommandPacket((float)roll, (float)pitch, (float)yaw, (char)thrust);
      
      //println("thrust " + thrust);
      //println("roll " + roll);
      //println("pitch " + pitch);
      //println("yaw " + yaw);      
    }
  }
  
  
  LeftPad_PosX = pad_roll  * (eyeSize-irisSize)/2;
  LeftPad_PosY = pad_pitch * (eyeSize-irisSize)/2;
  RightPad_PosX = pad_yaw  * (eyeSize-irisSize)/2;
  RightPad_PosY = pad_thrust * (eyeSize-irisSize)/2;
  
  
  // Draw Pad
  drawPad(0, 100, 140);
  drawPad(1, 300, 140);
}


public void drawPad(int type, int x, int y) {
  
  pushMatrix();
  translate(x, y);

  // draw white of eye
  stroke(0, 96, 0);
  strokeWeight(3);

  fill(255);
  ellipse(0, 0, eyeSize, eyeSize);

  // draw iris
  noStroke();
  fill(120, 100, 220);
  
  if( type == 0 )
    ellipse(LeftPad_PosX, LeftPad_PosY, irisSize, irisSize);
  else
    ellipse(RightPad_PosX, RightPad_PosY, irisSize, irisSize);

  popMatrix();
  
}


void keyPressed() 
{

  if ( key == 'c' ) 
  {
    mSky.connect();    
  } 
}