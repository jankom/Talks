import processing.net.*;

Client c;
String input;
int d[];
int cR;
int cG;
int cB;
Explosion explosion;

void setup() 
{
  size(350, 350);
  background(30,30,10);
  stroke(255,10,10);
  cR = round((float)Math.random()*255);
  cG = round((float)Math.random()*255);
  cB = round((float)Math.random()*255);
  framerate(20);
  // getCodeBase();
  c = new Client(this, "127.0.0.1", 7002);
  textFont(createFont("SanSerif", 15));
  explosion = new Explosion();
}

void draw() 
{
  fill(0, 12);
  rect(0, 0, width, height);
  if (mousePressed == true) {
    stroke(255);
    //line(pmouseX, pmouseY, mouseX, mouseY);
    c.write(cR+";"+cG+";"+cB+";"+mouseX+";"+mouseY+"\n");
  }
  if (c.available() > 0) {
    input = c.readString();
    d = int(split(input, ';')); // Split values into an array
    if (d.length == 5) {
      fill(140);
      text(input, round((float)Math.random()*250), round((float)Math.random()*250));
      explosion.make(d[3], d[4], d[0], d[1], d[2], 8, 0);
    }
    else 
    {
      fill(255,255,40);
      text(input, round((float)Math.random()*350), round((float)Math.random()*350));      
    }
  }
  
  //Explosions and particles
  explosion.update();
  explosion.draw();
}

class Explosion
{
  ArrayList particles;
  
  Explosion()
  { 
    particles = new ArrayList();
  }  
  
  void make(int x, int y, int cr, int cg, int cb, int size, int mode)
  {
    for(int angle=0; angle < 360; angle += 14)
    {
      int speed = 12;
      if (mode == 1) speed = 15;
      particles.add(new Particle(x, y, speed, radians(angle), cr, cg, cb, size, mode));  
    }
  }
  
  void update()
  {
    for (int i = 0; i < particles.size(); i++)
    {
      Particle p = (Particle) particles.get(i);
      p.update();  
      if (p.isDead())
      {
        particles.remove(i);
        i --;
      }
    }
  }
  
  void draw()
  {
    for (int i = 0; i < particles.size(); i++)
    {
      Particle p = (Particle) particles.get(i);
      p.draw();  
    }
  }
}

class Particle
{
  int mode;
  float x, y;
  float speed, angle;
  int cr;
    int cg;
      int cb;
  int mystatus, mysize;
  float vy; // velocityY
  
  Particle(int x_, int y_, float speed_, float angle_, int cr_, int cg_, int cb_, int mysize_, int mode_)
  {
    vy = 0;
    mystatus = 0;
    x = round(x_);
    y = round(y_);
    speed = speed_;
    angle = angle_;
    mysize = mysize_;
    mode = mode_; // 0 circle, 1 gravity
    cr = cr_;
    cg = cg_;
    cb = cb_;
  }    
    
  void update()
  {
    if (mode == 1) 
    {
      vy += 2.0;
    }
    x += cos(angle) * speed;
    y += sin(angle) * speed + vy;
    if (x > 550 || x < -mysize || y > 400 || y < -mysize)
    {
      mystatus = 99;
    }
  }
  
  void draw()
  {
    fill(cr, cg, cb);
    noStroke();
    ellipse(round(x), round(y), mysize, mysize);
      
      
  }
  
  boolean isDead()
  {
    return mystatus == 99;  
  }
  
}
