JSONObject configJson; // configuration of the stateMachine

/**
  Reads the configuration file
  Setup the configuration for the stateMachine
  Required: StateMacine Name
*/
void getConfig(String stateMachineName) {
  JSONObject dataJson = loadJSONObject("config_direction.json");
  JSONArray dataArray = dataJson.getJSONArray("config");
  for(int i =0; i < dataArray.size(); i++){
    JSONObject dataJsonObject = dataArray.getJSONObject(i);
    if(dataJsonObject.getString("stateMachineName").equals(stateMachineName)){
      configJson = dataJsonObject;                // Json object for the configuration of the stateMachine
    }
  }
}


/**
  Returns the initial state of the state machine
*/
String getInitialState() {
  return configJson.getString("initialState"); 
}


/**
  Returns the configuration of all the states in the state machine as a jsonArray
*/
JSONArray getStateConfigArray() {
  return configJson.getJSONArray("states");
}


/**
  Returns a jsonArray of all the possible events for the state machine
*/
JSONArray getEventsArray() {
  return configJson.getJSONArray("events");
}
