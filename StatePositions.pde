import java.util.Map;

Map < String, String > statesPositionMap = new HashMap < String, String > (); // {Key: StateName, Value: Centre of the state}
int stateGap = 200;   //Gap between the states in the UI

List < String > traversedStatesList = new ArrayList < String > (); // List of all the states already traversed
List < String> stateTransitionList = new ArrayList < String > ();  // List of string (state#transition)

/**
  Position of all the states in the UI
  Uses the initial state as the base and draws all the other states in reference to the initial state
  Directions for each state in reference to the previous state are from the configuration file 
*/

/**
  Creates a map of state and its position
*/
public void setPosition(String previousCentre, String nextState, String direction) { 
  if(!statesPositionMap.containsKey(nextState)) {                     // Set the position only when the poisition for the state is not present already
    String centreString = statesPositionMap.get(previousCentre);      // Poisition string of the previous state
    String[] positionXY = {};                                         // Array, element(0) : x, element(1) : y 
    positionXY = centreString.split("#");                             // Split the string into two elements in the array
    float x = Float.parseFloat(String.valueOf(positionXY[0]));        // x coordinate of the previous state
    float y = Float.parseFloat(String.valueOf(positionXY[1]));        // y coordinate of the previous state
    
    // conditions to get the position of the next state
    if(direction.equals("N")){ y = y - stateGap; }
    if(direction.equals("NE")){ x = x + stateGap; y = y - stateGap; }
    if(direction.equals("E")){ x = x + stateGap; }
    if(direction.equals("SE")){x = x + stateGap;y = y + stateGap; }
    if(direction.equals("S")){y = y + stateGap; }
    if(direction.equals("SW")){ x = x - stateGap; y = y + stateGap; }
    if(direction.equals("W")){ x = x - stateGap; }
    if(direction.equals("NW")){ x = x - stateGap; y = y - stateGap; }
  
    statesPositionMap.put(nextState, x + "#" +y);                     // Adding the position as a string (x#y) of the next state and its name
  }   
}


/**
  Returns the position of a state
  Required: stateName
*/
float[] getCentre(String stateName){  
    String statePosition = statesPositionMap.get(stateName);
    String[] positionXY = {};
    positionXY = statePosition.split("#");                            // Split the string into two elements in the array
    float x = Float.parseFloat(String.valueOf(positionXY[0]));        // x coordinate of the state
    float y = Float.parseFloat(String.valueOf(positionXY[1]));        // y coordinate of the state  
    return new float[] {x, y};
}


/**
  Traverse all the states 
  Make the stateTransition list (stateName#nextState)
*/
Boolean traverse(String nextState){  
  if(!traversedStatesList.contains(nextState)){
    traversedStatesList.add(nextState);                                         // Add the state on which currently traversing to a list to avoid traversing again
    for (int s = 0; s < statesConfigJArray.size(); s++) {                       // Traverse over all the states
      JSONObject stateObject = statesConfigJArray.getJSONObject(s);
      String stateName = stateObject.getString("stateName");
      if(stateName.equals(nextState)) {                                         // Traverse the transitions of the nextState only
        JSONArray transitionArray = stateObject.getJSONArray("transition");     
        for (int t = 0; t < transitionArray.size(); t++) {      
            JSONObject tObject = transitionArray.getJSONObject(t);
            //println("Event:", t, tObject.getString("event"));
            //println("PreviousState: ",stateName, "Next State:", tObject.getString("nextState"));
            //println("Direction:", tObject.getString("direction"), "\n");    
            setPosition(stateName, tObject.getString("nextState"), tObject.getString("direction"));    // Set the position of the state according to the direction
            stateTransitionList.add(stateName+ "#" +tObject.getString("nextState"));                   // List of string (state#transition)
            
            while(traverse(tObject.getString("nextState")))                    //Recursively traversing the digraph until all the states are traversed
              traverse(tObject.getString("nextState"));              
        }
      }    
    }    
    return true;
  } else return false;
}
