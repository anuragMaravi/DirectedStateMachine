String currentState = "";



/**
  Returns a list of all the events possible for the state machine
*/
List < String > getEvents() {
 List < String > list = new ArrayList < String > ();
 for (int e = 0; e < eventsJArray.size(); e++) {                // eventsJArray from the configuration
  JSONObject obj = eventsJArray.getJSONObject(e);
  list.add(obj.getString("eventName"));                         // Add the events to the list
 }
 return list;
}


/**
  Check if the eventMessage from the sensor is valid for this state machine or it is a noise
*/  
Boolean eventValid(String eventMessage) {
 if (eventsList.contains(eventMessage))                        // If the eventLabel is a valid event for the current state machine
  return true;
 else
  return false;
}


/**
  Checks for the possible transition on the current state
  Returns the next state
*/ 
String getNextState(String currentState, String transition) {
 for (int s = 0; s < statesConfigJArray.size(); s++) {
  JSONObject obj = statesConfigJArray.getJSONObject(s);
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


/**
  Returns the current state
  If there is no current state, returns initial state as the current state
*/ 
String getCurrentState() {
 if (currentState.equals(""))
  return initialState;
 else
  return currentState;
}

/**
  Updates the current state
*/
void setCurrentState(String nextState) {
 currentState = nextState;
}
