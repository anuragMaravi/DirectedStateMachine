import java.util.Arrays;
import java.util.List;
import java.util.Map;

float radius = 60; //Radius of the states
float arrowTh = 2.0; //Thickness of the arrow
int gap = 200; //Gap between the states
int arrowColor = 200;
float initX;
float initY;

List < String > statesList = new ArrayList < String > ();
Map < String, String > stateCentreMap = new HashMap < String, String > (); //Key: StateName, Value: Centre of the state
List < String> stateTransitionList = new ArrayList < String > ();

JSONObject configJson;
String initialState;
JSONArray states;



void setup(){
  size(1200, 600);
  background(0);
 
  initX = width*0.5;
  initY = height*0.5;
  
  configJson = loadJSONObject("config_direction.json");
  initialState = configJson.getString("initialState");
  states = configJson.getJSONArray("states");
  stateCentreMap.put(initialState, initX + "#" +initY);
  
  //Setup the centre of the circle and 
  traverse(initialState);  
  
  //Using the centre map to draw all the states(circles)
  for (Map.Entry<String,String> entry : stateCentreMap.entrySet()) {
    String key1 = entry.getKey();
    String value = entry.getValue();
    String[] arrOfStr = {};
    arrOfStr = value.split("#");
    float x = Float.parseFloat(String.valueOf(arrOfStr[0]));
    float y = Float.parseFloat(String.valueOf(arrOfStr[1]));
    drawCircle(x, y, key1);
  }
  
  //Using state transition list to make all the arrows
  for(String pair : stateTransitionList){
    String[] arrOfStr = {};
    arrOfStr = pair.split("#");
    float centreF[] = getCentre(arrOfStr[0]);
    float centreT[] = getCentre(arrOfStr[1]);    
    drawArrow(centreF[0], centreF[1], centreT[0], centreT[1]);
  }
  
}



void draw(){
  
}

//Traverse the graph: make centre map and transition list
Boolean traverse(String nextState){  
  if(!statesList.contains(nextState)){
    statesList.add(nextState);

    for (int s = 0; s < states.size(); s++) {
      JSONObject obj = states.getJSONObject(s);
      String stateName = obj.getString("stateName");
      if(stateName.equals(nextState)) {
        JSONArray transitionC = obj.getJSONArray("transition");
        for (int t = 0; t < transitionC.size(); t++) {      
            JSONObject tObject = transitionC.getJSONObject(t);
            //println("Event:", t, tObject.getString("event"));
            //println("PreviousState: ",stateName, "Next State:", tObject.getString("nextState"));
            //println("Direction:", tObject.getString("direction"), "\n");    
            setCentre(stateName, tObject.getString("nextState"), tObject.getString("direction"));
            stateTransitionList.add(stateName+ "#" +tObject.getString("nextState"));
            
            //Recursively traversing the digraph until all the states are traversed
            while(traverse(tObject.getString("nextState")))
              traverse(tObject.getString("nextState"));              
        }
      }    
    }    
    return true;
  } else return false;
}

//Sets the centre of the circle according to the directions provided in the map
public void setCentre(String previousCentre, String nextState, String direction) { 
  
  if(!stateCentreMap.containsKey(nextState)) {    
    String centreString = stateCentreMap.get(previousCentre);
    String[] arrOfStr = {};
    arrOfStr = centreString.split("#");
    float x = Float.parseFloat(String.valueOf(arrOfStr[0]));
    float y = Float.parseFloat(String.valueOf(arrOfStr[1]));
    
    if(direction.equals("N")){ y = y - gap; }
    if(direction.equals("NE")){ x = x + gap; y = y - gap; }
    if(direction.equals("E")){ x = x + gap; }
    if(direction.equals("SE")){x = x + gap;y = y + gap; }
    if(direction.equals("S")){y = y + gap; }
    if(direction.equals("SW")){ x = x - gap; y = y + gap; }
    if(direction.equals("W")){ x = x - gap; }
    if(direction.equals("NW")){ x = x - gap; y = y - gap; }
  
  stateCentreMap.put(nextState, x + "#" +y);
  } else println(nextState, "already has a centre");  
}

//Returns the centre of the circle by the stateName
float[] getCentre(String stateName){  
    String value = stateCentreMap.get(stateName);
    String[] arrOfStr = {};
    arrOfStr = value.split("#");
    float x = Float.parseFloat(String.valueOf(arrOfStr[0]));
    float y = Float.parseFloat(String.valueOf(arrOfStr[1]));    
    return new float[] {x, y};
}

public void drawCircle(float x, float y, String stateName) {
  fill(255);
  stroke(0);
  strokeWeight(0);
  ellipse(x, y, 2*radius, 2*radius);
  textSize(16);
  fill(0);
  textAlign(CENTER, CENTER);
  text(stateName, x, y);
}

public void drawArrow(float cx0, float cy0, float cx1, float cy1) {
  // These will be the points on the circles circumference
  float px0, py0, px1, py1;
  // the angle of the line joining centre of circle c0 to c1
  float angle = atan2(cy1-cy0, cx1-cx0);
  px0 = cx0 + radius * cos(angle);
  py0 = cy0 + radius * sin(angle);
  px1 = cx1 + radius * cos(angle + PI);
  py1 = cy1 + radius * sin(angle + PI);
  // Calculate the arrow length and head size
  float arrowLength = sqrt((px1-px0)*(px1-px0) +(py1-py0)*(py1-py0));
  float arrowSize = 2.5 * arrowTh;
  // Setup arrow colours and thickness
  strokeWeight(arrowTh);
  stroke(arrowColor);
  fill(arrowColor);
  // Set the drawing matrix as if the arrow starts
  // at the origin and is along the x-axis
  pushMatrix();
  translate(px0, py0);
  rotate(angle);
  // Draw the arrow shafte
  line(0, 0, arrowLength, 0);
  //  draw the arrowhead
  beginShape(TRIANGLES);
  vertex(arrowLength, 0); // point
  vertex(arrowLength - arrowSize, -arrowSize);
  vertex(arrowLength - arrowSize, arrowSize);
  endShape();
  popMatrix();
}
