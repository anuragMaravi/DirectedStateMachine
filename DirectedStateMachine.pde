import java.util.Arrays;
import java.util.List;


//State Properties
String initialState;                          // Initial state of the stateMachine
JSONArray statesConfigJArray;                 // Configuration of all the states
JSONArray eventsJArray;                       // Configuration of all the events

color themeColor = color(253, 190, 45);       // Theme color for the UI
String stateMachineName = "Microwave";        // Name of the state machine on the configuration file
                                              // @ToDo: Use a drop down on the UI to select the state machine
String eventName = "";                        // Event name from the data stream
int streamIndex = 0;                          // Index of the data stream

List < String > eventsList = new ArrayList < String > ();                    // List of possible events for the current state machine
Map < String, Boolean > stateActivity = new HashMap < String, Boolean > ();  // True for the active state and false for all other states

// Setup ---------------------------------------------------------------------------------------------

void setup(){
  size(1280, 720);
  noLoop();
  
  //From: StateConfig.pde
  getConfig(stateMachineName);                // Setup the configuration for the stateMachine
  initialState = getInitialState();           // Initial state of the state machine
  statesConfigJArray = getStateConfigArray(); // JsonArray of all the states' configuration
  eventsJArray = getEventsArray();            // JsonArray of all the states' configuration
  eventsList = getEvents();                   //contains a list of events/transistion conditions

 
  // Set the base as the initialState and center of the canvas as initial position
  statesPositionMap.put(initialState, width*0.5 + "#" + height*0.5);  
  
  //From: DataStream
  initializeDataStream();                     // Makes connection witha the broker and gets the stream of data                
}

// Draw ---------------------------------------------------------------------------------------------

void draw(){
  background(0);
  
    
  textSize(36);fill(themeColor);textAlign(CENTER, CENTER);                          
  text(stateMachineName + " State Machine", width*0.5, 48);                        // State Machine title
  
  /** 
      Start traversing from the initial state 
      Set position of the states
      Setup a state-transition rule
  */  
  traverse(initialState);  
  
  //Draw all states on the UI
  for (Map.Entry<String,String> entry : statesPositionMap.entrySet()) {
    String key1 = entry.getKey();
    String value = entry.getValue();
    String[] arrOfStr = {};
    arrOfStr = value.split("#");
    float x = Float.parseFloat(String.valueOf(arrOfStr[0]));
    float y = Float.parseFloat(String.valueOf(arrOfStr[1]));
    drawState(x, y, key1, 255);
  }
  
  //Draw arrows between the states
  for(String pair : stateTransitionList){
    String[] arrOfStr = {};
    arrOfStr = pair.split("#");
    float centreFrom[] = getCentre(arrOfStr[0]);
    float centreTo[] = getCentre(arrOfStr[1]);    
    drawArrow(centreFrom[0], centreFrom[1], centreTo[0], centreTo[1]);
  }
  
  
  if(message.length() != 0){
    JSONObject json = parseJSONObject(message);
    JSONObject fields = json.getJSONObject("fields");
    eventName = fields.getString("value");   
    println("\n" + streamIndex + " "  + json.getString("time") + " " + eventName); // Logging the data stream
    streamIndex++;    
    fill(255); textSize(16); text(eventName,80,40);                                // Text on the UI 
    String[] eventMessage = {};                                                    // Array to store the message after spliting
    eventMessage = eventName.split(":");                                           // eventMessage[0] : START/END, eventMessage[1] : Event Label
    String eventLabel = eventMessage[1];                                           // eventLabel, which is used to check the transition for the state
    println("InputData: ", eventLabel);
    println("Valid Event: " + eventValid(eventLabel)); 
    if (eventValid(eventLabel)) { 
      println("Current State: ", getCurrentState());
      String nextState = getNextState(getCurrentState(), eventLabel);
      println("Next State: ", nextState);
      if (!nextState.equals("Error")) {
      setCurrentState(nextState);                                                  // Update next state as the current state
      for (Map.Entry<String, Boolean> entry : stateActivity.entrySet())            // Reset all stateActivity to false
        stateActivity.put(entry.getKey(), false);
      stateActivity.put(getCurrentState(), true);                                  // Update the current state as active
     
     fill(255);textSize(16);
     text("Current State: " + getCurrentState(), width/2, height - 40);             // Text to show the current state on the UI
    } else {
     println("No transition for this event on current state");
     fill(255);textSize(16);
     text("No transition for this event on current state", width/2, height - 40);   // Text when no transition possible
    }
   }
       println("Updated Current State:", getCurrentState());      
   } else println("No new data");
  
  //Updating the 
  float updatedPoistion[] = getCentre(getCurrentState());                           // Get the position of the updated state
  drawState(updatedPoistion[0], updatedPoistion[1], getCurrentState(), themeColor); // Update the state with theme color/Make the state active 
  
}
