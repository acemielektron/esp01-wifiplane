//**************************************************
// WiFi Controlled Tiny Airplane
// Android App Processing file
// By Ravi Butani
// Rajkot INDIA
// Instructables page:https://www.instructables.com/id/WIFI-CONTROLLED-RC-PLANE/
//***************************************************
import hypermedia.net.*; // import UDP library
import ketai.sensors.*;  // import Ketai Sensor library
import ketai.ui.*;
int app_start=1;
int DC_UPDATE = 1;//old 3 gives flickring on plane
byte P_ID = 1;
int dc_count = 0;
int lock = 0;
int gas = 0;
int rssi=0;
int vcc=0;
int l_speed = 0;
int r_speed = 0;
int vib_count = 0;
int rst_count = 0;
UDP udp;             // define the UDP object
KetaiSensor sensor;  // define the Ketai sensor object
KetaiVibrate vibe;
float accelerometerX, accelerometerY, accelerometerZ;
int exprt_flag = 0;
float diff_power = 2.2;
int remotPort = 6000;
int localPort = 2390;
int offsetl = 0;
int offsetr = 0;
String remotIp = "192.168.43.255";  // the remote IP address
void setup()
{
  size(displayWidth,displayHeight);
  orientation(PORTRAIT);
  udp = new UDP( this, localPort );
  udp.listen( true );
  sensor = new KetaiSensor(this);
  vibe = new KetaiVibrate(this);
  sensor.start();
}

void draw()
{
  background(125, 255, 200);
  fill(255);
  stroke(163);
  rect(0,0,width/4,height/4);
  rect(3*width/4,0,width/4,height/4);
  rect(0,height/4,width/4,height/4);
  rect(3*width/4,height/4,width/4,height/4);
  rect(0,7*height/8,width,height/8);
  fill(color(255,100,60));
  rect(width/4,0,width/2,7*height/8);
  fill(color(100,150,255));
  rect(width/4,0,width/2,((7*height)/8)-(gas*7*height)/(8*127));
  
  textSize(height/12);
  textAlign(CENTER,CENTER);
  fill(color(50,100,255));
  text("+", width/8, height/8 - 10);
  text("-", width/8, 3*height/8 - 10);
  text("+", 3*width/4 + width/8, height/8 - 10);
  text("-", 3*width/4 + width/8, 3*height/8 - 10);
  fill(0);
  text(gas*100/127, width/2, height/2);
  text(offsetl, width/8, height/4 - 10);
  text(offsetr, 3*width/4 + width/8, height/4 -10);
  
  if(exprt_flag == 0){text("BG", width/8, height/2 + height/6);}
  else if(exprt_flag == 1){text("EX", width/8, height/2 + height/6);}
  if(lock == 0)text("LOCKED", width/2, 7*height/8 + height/16);
  else if(lock == 1)text("ACTIVATED", width/2, 7*height/8 + height/16);
  textSize(height/14);
  fill(255);
  if (rssi == 0 )text("-"+Character.toString('\u221e')+"dBm", width/2, 3*height/4);
  else text("-"+rssi+"dBm", width/2, 3*height/4);
  text((vcc/10)+"."+(vcc%10)+"V", width/2, 3*height/4 + height/12);
  fill(0);
  textSize(height/30);
  textAlign(CENTER,CENTER);
  text("Instructables", width/2, height/20);
  text("WiFi Plane App", width/2, 2*height/20);
  text("By Ravi Butani", width/2, 3*height/20);
  textSize(height/12);
  
   delay(1);
   dc_count++;
   if(dc_count >= DC_UPDATE)
  {
    rst_count++;
    if(rst_count >= 200)
    {
      vcc = 0;
      rssi = 0;
    }
    dc_count = 0;
    if(accelerometerX > 1.5){accelerometerX = accelerometerX - 1.5;}
    else if(accelerometerX < -1.5){accelerometerX = accelerometerX + 1.5;}
    else {accelerometerX = 0;}
    l_speed = (int)((float)gas + (float)offsetl + accelerometerX*(float)diff_power);
    r_speed = (int)((float)gas + (float)offsetr - accelerometerX*(float)diff_power);
    if(l_speed >= 127 )l_speed = 127;
    else if(l_speed <= 1)l_speed = 1;
    if(r_speed >= 127 )r_speed = 127;
    else if(r_speed <= 1)r_speed = 1;
    byte message[]  = {'1','2','3'};  // the message to send
    message[0] = P_ID;
    if(lock == 1){
      message[1] = (byte)l_speed;
      message[2] = (byte)r_speed;
      vib_count++;
      if(vcc<35 && vib_count<5){vibe.vibrate(1000);}
      if(vib_count>=40)vib_count = 0;
    }
    else if(lock == 0){
      message[1] = (byte)0x01;
      message[2] = (byte)0x01;
    }
    println(message[1]);
    println(message[2]);
    String msg = new String(message);
    udp.send( msg, remotIp, remotPort );
    println("msgsend");
  }
   
}

void onAccelerometerEvent(float x, float y, float z)
{
  accelerometerX = x;
  accelerometerY = y;
  accelerometerZ = z;
}

void mouseDragged()
{
  if(mouseY<7*height/8 && mouseX>width/4 && mouseX<3*width/4 && lock==1)  gas = 127-(int)(((float)mouseY/((float)(7*height/8)))*(float)127);
}

void mousePressed()
{
  if(mouseX<width/4 && mouseY<height/4) offsetl++;
  else if(mouseX<width/4 && mouseY<height/2) offsetl--;
  else if(mouseX>3*width/4 && mouseY<height/4) offsetr++;
  else if(mouseX>3*width/4 && mouseY<height/2) offsetr--;
  else if(mouseX<width/4 && mouseY<3*height/4){
    if(exprt_flag == 0){exprt_flag = 1; diff_power = 3.9;}
    else{exprt_flag = 0; diff_power = 2.2;}
  }
  else if(mouseY>7*height/8){
    gas=0; 
    if (lock == 0)lock =1;
    else lock=0;
  }
}

void receive( byte[] data, String ip, int port ) {  // <-- extended handler
  rst_count=0;
  rssi = data[1];
  vcc  = data[2]+3;
}