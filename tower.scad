$fa = 1;
$fs = 1;


numberOfParts = 4;  // total number of parts
diameter = 30;  // diamater of thickest part
height = 15;  // height of one part

thickness = 1.5;  // thickness of one part
distance = .75; // distance between two parts
cutAngleWidth = 40;  // width of the cut
cutAnglePerPart = 360/8;
knobHeight = 3;
knobWidth = 2;


// you probably don't need these
exploded = 1;  // 0 - collapsed tower, 1 - exploded tower
overlap = thickness
totalHeight = numberOfParts * height - (numberOfParts - 1) * overlap;

// --- calculations
radius = diameter / 2;
smallestRadius = radius - numberOfParts * thickness - (numberOfParts - 1) * distance;
cutTotalAngle = cutAnglePerPart * numberOfParts;

module ring(height, outerRadius, innerRadius) {
  difference() {
      cylinder(h = height, r = outerRadius);
      translate([0, 0, -height/2]) {
        cylinder(h = height*2, r = innerRadius);
      }
  }
}

module ringSector(height, outerRadius, innerRadius, angle) {
  difference() {
    ring(height, outerRadius, innerRadius);

    translate([-500, 0, -100])
    cube(size = 1000, center = false);

    rotate([0, 0, -180 + angle])
    translate([-500, 0, -100])
    cube(size = 1000, center = false);
  }
}


//  radius * angle = len
function arcAngle(radius, arcLength) = arcLength * 360 / (radius * 2 * 3.141593);

module knob(outerRadius) {
  assign(knobAngle = arcAngle(outerRadius, knobWidth)) {
    echo("outerRadius", outerRadius, "knobAngle", knobAngle);
    rotate([0, 0, -knobAngle / 2]) {
      ringSector(knobHeight, outerRadius + thickness / 2, outerRadius, knobAngle);
    }
  }
}

module knobPath(outerRadius) {
  assign(knobAngle = arcAngle(outerRadius, knobWidth + distance * 2)) {
    rotate([0, 0, - knobAngle / 2]) {
      ringSector(height - overlap, outerRadius + thickness / 2, outerRadius - distance, knobAngle);

      translate([0, 0, height - overlap - knobHeight])
      ringSector(knobHeight, outerRadius + thickness / 2, outerRadius - distance, min(70, arcAngle(outerRadius, knobWidth * 3 + distance * 2)));

    }
  }
}

module knobs(outerRadius) {
  knob(outerRadius);

  rotate([0, 0, 90])
  knob(outerRadius);


  rotate([0, 0, 180])
  knob(outerRadius);


  rotate([0, 0, 270])
  knob(outerRadius);
}


module knobPaths(outerRadius) {
  knobPath(outerRadius);

  rotate([0, 0, 90])
  knobPath(outerRadius);


  rotate([0, 0, 180])
  knobPath(outerRadius);


  rotate([0, 0, 270])
  knobPath(outerRadius);
}

for (i = [0 : numberOfParts - 1]) {
  assign(outerRadius = radius - (thickness + distance) * i) {
    translate([0, 0, i * (height - overlap - distance - knobHeight) * exploded]) {
      difference() {
        ring(height, outerRadius, outerRadius - thickness);

        if (i != numberOfParts - 1) {
          knobPaths(outerRadius - thickness);
        }
      }

      if (i != 0) {
        knobs(outerRadius);
      }
    }
  }
}
