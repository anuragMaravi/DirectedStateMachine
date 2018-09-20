// State properties
float stateRadius = 60; //Radius of the states
color stateColor = (255);

// Arrow properties
float arrowThickness = 2.0; //Thickness of the arrow
int arrowColor = 200;


/**
  Draws the state and its label
*/
public void drawState(float x, float y, String stateName, color stateColor) {
  fill(stateColor);
  stroke(0);
  strokeWeight(0);
  ellipse(x, y, 2*stateRadius, 2*stateRadius); // Cricle with diameter
  textSize(16);                                // State label size
  fill(0);                                     // Label color
  textAlign(CENTER, CENTER);
  text(stateName, x, y);                       // Add label to the state
}


/**
  Draws the arrow between circles (states) having the points on their edges
*/
public void drawArrow(float centerX0, float centerY0, float centerX1, float centerY1) {
  
  float px0, py0, px1, py1;                                   // Points on the circles circumference
  float angle = atan2(centerY1-centerY0, centerX1-centerX0);  // the angle of the line joining centre of circle c0 to c1
  px0 = centerX0 + stateRadius * cos(angle);
  py0 = centerY0 + stateRadius * sin(angle);
  px1 = centerX1 + stateRadius * cos(angle + PI);
  py1 = centerY1 + stateRadius * sin(angle + PI);
  float arrowLength = sqrt((px1-px0)*(px1-px0) +(py1-py0)*(py1-py0));    // Calculate the arrow length and head size
  float arrowSize = 2.5 * arrowThickness;
  strokeWeight(arrowThickness);                    // Setup arrow thickness
  stroke(arrowColor);                       // Setup arrow colors
  fill(arrowColor);
  pushMatrix();                             // Set the drawing matrix at the origin
  translate(px0, py0);                      // Move the arrow to point at circle0
  rotate(angle);                            // Rotate the line towards circle1
  line(0, 0, arrowLength, 0);               // Draw the arrow shafte
  beginShape(TRIANGLES);                    // Draw the arrowhead
  vertex(arrowLength, 0);                   
  vertex(arrowLength - arrowSize, -arrowSize);
  vertex(arrowLength - arrowSize, arrowSize);
  endShape();
  popMatrix();
}
