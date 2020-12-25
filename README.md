# BEng-Project - CircuitTable

![Cover](https://user-images.githubusercontent.com/37272242/88901871-f6b7a280-d283-11ea-8f46-f5768e14defe.png)

This is a repo created for the final year (BEng) project at Imperial College London.

Complete feature showcase: https://youtube.com/playlist?list=PLd89wyPwlBLTz_Mrqj-FfSWpPJAo7MBhb

## Demo

For more information please contact me!

**Software with tested and working disc tracking** can be found in the `Complete-tests`  folder.

**Software that is being worked on for functionality** can be found in the `Initial-tests` folder.

The following relates to the **exported software for interface testing**:

Notes: 
- Latest release `v2.app` currently only works on MacOS (pending Windows testing). 
- (v2) LED shader and HD graphics disabled due to `Processing 3` exporting issues (https://github.com/processing/processing/issues/5983).


### Installation:
Latest working versions of the interface will be found in the `Releases` folder. Download the **folder** corresponding to the version `v_`.

Before running, make sure the latest version of `ngspice` is installed as follows:

<!--#### For Windows:--> 
  
  <!--Installation instructions can be found at: http://ngspice.sourceforge.net/download.html-->
  
##### For MacOS: 
  
  Make sure `Homebrew` is installed. (Instructions at : https://brew.sh/)
  
  Install `ngspice` by entering `brew install ngspice` in Terminal.
  
  Check that it is installed by entering `ngspice` in Terminal. A text UI should come up.
  
### Running:

##### For MacOS:
Once `ngspice` is installed, run the application `v_.app` from within the folder.

### Controls:
- Adding a disc to the interface — Click on the ’+’ button in the top left corner.
- Removing a disc from the interface — Click on the ’−’ button in the top left corner, then click on the
disc that should be removed.
- Rotating a disc — While holding the left mouse button on a disc, scroll up/down to rotate the disc clockwise/anticlockwise.
- Show debugging text — Press the ’x’ key.
- (v2) Saving a circuit layout — Press the ’s’ key.
- (v2)  Loading a circuit layout — Press the ’l’ key.

### Versions:
##### v2
- Full component functionality:
  - Passive components: Resistors, Capacitors, Inductors.
  - Switches.
  - Power sources: DC voltage and current sources, Sinusoidal and Triangular wave voltage sources.
  - Diodes: PN diodes, (RGB) LEDs.
  - Active Components: n-type and p-type BJTs, n-channel and p-channel MOSFETs.
  - Measurement Tools: Voltmeters, Ammeters, Oscilloscope probes.
- Components sorted into categories.
- Time zone added for frequency changing.
- Simulation speed changeable.
- LED Shaders.
- Save and load functionality.
- Settings: Added Disc Size

##### v1
- Most components functioning:
  - Resistor, Capacitor, Inductor, Switch, DC voltage source, Diode, NPN and PNP BJTs, Oscilloscope, Voltmeter.
- Working simulation.
- Settings: Scroll and Shake Sensitivity.
