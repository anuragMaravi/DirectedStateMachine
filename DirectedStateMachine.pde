import java.util.Arrays;
import java.util.List;
import java.util.Map;

import com.rabbitmq.client.*;
import java.io.IOException;
import java.util.concurrent.TimeoutException;

float radius = 60; //Radius of the states
float arrowTh = 2.0; //Thickness of the arrow
int gap = 200; //Gap between the states
int arrowColor = 200;
color stateColor = (255);
float initX;
float initY;

List < String > statesList = new ArrayList < String > ();
Map < String, String > stateCentreMap = new HashMap < String, String > (); //Key: StateName, Value: Centre of the state
List < String> stateTransitionList = new ArrayList < String > ();

JSONObject configJson;
String initialState;
JSONArray states;

//RabbitMQ Configuration
String EXCHANGE_NAME = "master_exchange";
String userName = "";
String password = "";
String virtualHost = "/";
String hostName = "128.237.158.26";
String sensorId = "80ee9a0e-e420-4263-9629-46ce4c3f7ae4";
int port = 5672;

//Message from the broker
String message = "";
String dateD = "";
String eventName = "";

int logC = 0;
//Values from configuration file
List < String > eventsList = new ArrayList < String > ();
String currentState = "";
Map < String, Boolean > stateActivity = new HashMap < String, Boolean > ();



void setup(){
  size(1280, 720);
  noLoop();

 
  
  
  //Data stream from the broker
  try{
   ConnectionFactory factory = new ConnectionFactory();
   factory.setUsername(userName);
   factory.setPassword(password);
   factory.setVirtualHost(virtualHost);
   factory.setHost(hostName);
   factory.setPort(port);
   Connection connection = factory.newConnection();
   Channel channel = connection.createChannel();

   channel.exchangeDeclare(EXCHANGE_NAME, BuiltinExchangeType.DIRECT);
   String queueName = channel.queueDeclare().getQueue();
   channel.queueBind(queueName, EXCHANGE_NAME, sensorId);

   System.out.println(" [*] Waiting for messages. To exit press CTRL+C");

   Consumer consumer = new DefaultConsumer(channel) {
     @Override
     public void handleDelivery(String consumerTag, Envelope envelope,
                                AMQP.BasicProperties properties, byte[] body) throws IOException {
       message = new String(body, "UTF-8");
       message = message.replace('\'','\"');
       message = message.replace("u\"","\"");
       redraw();
       
     }
   };
   channel.basicConsume(queueName, true, consumer);

  } catch(IOException i) {
    println(i);
  } catch(TimeoutException i) {
    println(i);
  }  
  
}



void draw(){
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
    drawCircle(x, y, key1, 255);
  }
  
  //Using state transition list to make all the arrows
  for(String pair : stateTransitionList){
    String[] arrOfStr = {};
    arrOfStr = pair.split("#");
    float centreF[] = getCentre(arrOfStr[0]);
    float centreT[] = getCentre(arrOfStr[1]);    
    drawArrow(centreF[0], centreF[1], centreT[0], centreT[1]);
  }
  
  if(message.length() != 0){
         JSONObject json = parseJSONObject(message);
         JSONObject fields = json.getJSONObject("fields");
         eventName = fields.getString("value");
         dateD = String.valueOf(json.getString("time"));
      
         //Logging
         println("\n" + logC + " "  + dateD + " " + eventName);
         logC++;
         //EventName on UI
         fill(255);
         textSize(16);
         text(eventName,80,40);
      
         //Split the message
         String[] arrOfStr = {};
         arrOfStr = eventName.split(":");
         //println(arrOfStr[0] + " " + arrOfStr[1]);
       
       
           //----------------------------------------------------
           /***From configuration file 
           Using the concept of finite state machine
           **/
           String dat = arrOfStr[1]; // Input stream goes here
           println("InputData: ", dat);
           
           //From configuration file
           eventsList = getEvents(); //contains a list of events/transistion conditions
           println("Valid Event: " + eventValid(dat)); 
           if (eventValid(dat)) { 
            println("Current State: ", getCurrentState());
            String nextState = getNextState(getCurrentState(), dat);
            println("Next State: ", nextState);
            if (!nextState.equals("Error")) {
             setCurrentState(nextState);
             
 
             //Reset all values to false
             for (Map.Entry<String, Boolean> entry : stateActivity.entrySet()) {
                stateActivity.put(entry.getKey(), false);
             }
             stateActivity.put(getCurrentState(), true);
             
             //Text
             fill(255);
             textSize(16);
             text("Current State: " + getCurrentState(), width/2,height - 40);
            } else {
             println("No transition for this event on current state");
             fill(255);
             textSize(16);
             text("No transition for this event on current state", width/2, height - 40);
            }
           }
           println("Updated Current State:", getCurrentState());      
       } else println("No new data");
       
  float centreF[] = getCentre(getCurrentState());
  color a = color(253, 190, 45);
  drawCircle(centreF[0], centreF[1], getCurrentState(), a);
  
}

//*******************************
//Finite State Machine Conditions
//*******************************
//Getting the events/transitions from the configuration file, returns a list of valid events
//#######ToDo: Use the events type to smooth the data
List < String > getEvents() {
 List < String > list = new ArrayList < String > ();
 JSONArray events = configJson.getJSONArray("events");
 for (int e = 0; e < events.size(); e++) {
  JSONObject obj = events.getJSONObject(e);
  list.add(obj.getString("eventName"));
 }
 return list;
}

//Check if the eventMessage from the sensor is valid for this state machine or it is a noise
Boolean eventValid(String eventMessage) {
 if (eventsList.contains(eventMessage))
  return true;
 else
  return false;
}

//Gives the current state
String getCurrentState() {
 if (currentState.equals(""))
  return configJson.getString("initialState");
 else
  return currentState;
}

//Add states and its transitions
String getNextState(String currentState, String transition) {
 JSONArray states = configJson.getJSONArray("states");
 for (int s = 0; s < states.size(); s++) {
  JSONObject obj = states.getJSONObject(s);
  String stateName = obj.getString("stateName");
  if (stateName.equals(currentState)) {
   JSONArray transitionC = obj.getJSONArray("transition");
   for (int t = 0; t < transitionC.size(); t++) {
    JSONObject tObject = transitionC.getJSONObject(t);
    if (tObject.getString("event").equals(transition)) {
     return tObject.getString("nextState");
    } else {
     println("Transition not found", t);
    }
   }
   break;
  } else println("State not found at", s);
 }
 return "Error";
}

//Set the current state
void setCurrentState(String nextState) {
 currentState = nextState;
}

//*******************************
//Pre load the state machine
//*******************************
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

public void drawCircle(float x, float y, String stateName, color stateColor) {
  fill(stateColor);
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
