import intel.pcsdk.*;

short[] depthMap;

int[] depth_size = new int[2];
int[] rgb_size = new int[2];
  
PImage rgbImage, depthImage;
PXCUPipeline session;
int x = 320;
int y = 240;
void setup()
{
  size(640, 480);
  ellipseMode(CENTER);
  session = new PXCUPipeline(this);
  if (!session.Init(PXCUPipeline.COLOR_VGA|PXCUPipeline.DEPTH_QVGA|PXCUPipeline.GESTURE))
    exit();

  if(session.QueryRGBSize(rgb_size))
    rgbImage=createImage(rgb_size[0], rgb_size[1], RGB);

  if(session.QueryDepthMapSize(depth_size))
  {
    depthMap = new short[depth_size[0] * depth_size[1]];
    depthImage=createImage(depth_size[0], depth_size[1], ALPHA);
  }
}

PXCMGesture.Gesture gest = new PXCMGesture.Gesture();
void draw()
{ 
  background(0);

  if (session.AcquireFrame(false))
  {
    session.QueryRGB(rgbImage);
    session.QueryDepthMap(depthMap);
    for (int i = 0; i < depth_size[0]*depth_size[1]; i++)
    {
      depthImage.pixels[i] = color(map(depthMap[i], 0, 2000, 0, 255));
    }
    depthImage.updatePixels();


    if(session.QueryGesture(PXCMGesture.GeoNode.LABEL_ANY, gest))
    {
      ParseGesture(gest) ;
    }

    session.ReleaseFrame();
  }
  
  image(rgbImage, 0, 0, 320, 240);
  image(depthImage, 0, 240, 320, 240);
  ellipse(x,y,60,60) ;
}

void ParseGesture(PXCMGesture.Gesture gest)
{
  if (!gest.active)
    return ;
    
  if (gest.label == PXCMGesture.Gesture.LABEL_NAV_SWIPE_LEFT)
  {
    println("Swipe left");
    if( x > 10)
      x -= 10 ;
  }
  else if (gest.label == PXCMGesture.Gesture.LABEL_NAV_SWIPE_RIGHT)
  {
    println("Swipe right");
    if( x < 630)
      x += 10 ;
  }
  else if (gest.label == PXCMGesture.Gesture.LABEL_POSE_THUMB_DOWN)
  {
    println("Thumbs down");
    if( y < 470 )
      y += 10 ;
  }
  else if (gest.label == PXCMGesture.Gesture.LABEL_POSE_THUMB_UP)
  {
    println("Thumbs up");
    if( y > 10 )
      y -= 10 ;
  }else if (gest.label == PXCMGesture.Gesture.LABEL_HAND_CIRCLE)
  {
    println("Circle");
    x = 320 ;
    y = 240 ;
  }
}

void exit()
{
  session.Close(); 
  super.exit();
}
