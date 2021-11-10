# HYMN

A spirit needs your help in composing his funeral song - and so discover the circumstances of their death.

Different sequential parts are combined to form a final, memory-inducing piece. Although playable using computer screen and controls, the experience is intended for use with a VR headset. 


### Requirements
<ul>
  <li>Max/MSP</li>
  <ul>
    <li>Package: VR</li>
    <li>Package: PeRColate</li>
  </ul>
  <li>Processing</li>
  <ul>
    <li>Package: OSCP5</li> 
  </ul>
  </ul>
 
 

### Instructions
<ul>
  <li>Unzip the wavsamples archive into the same folder as the Max/MSP patches: HymnVR and HymnNoVR. The Processing sketch ‘HymnSketch’ can be placed in any subdirectory.</li> </ul>
<ul>
  <li>With VR Headset</li>
 <li>Activate your VR Headset (definitely supported: HTC Vive. Probably supported: Oculus).</li>
<li>Open the Max/MSP patch: HymnVR</li>
<li>Open the relevant subpatch:</li><ul>
<li>Double click ‘p tracking’ in the main patch</li>
  <li>Then double click ‘p vrControls’ </li></ul>
<li>Make sure the DAC is active in the subpatch, and that no missing-file errors appear in the Console</li>
<li>Open Hymn.pde in Processing</li>
<li>Run the application</li>
<li>Make sure the screen is active and press the ‘s’ button to start the application</li>

</ul>
<ul>
  <li>Without VR Headset</li>
   <li>Open the Max/MSP patch: HymnNoVR</li>
 <li>Make sure the DAC is active in the patch, and that no missing-file errors appear in the Console</li>
  <li>Open Hymn.pde in Processing</li>
<li>Change line 11, ‘usingComputerControls’, to true </li>
<li>Run the application</li>
<li>Make sure the screen is active and press the ‘s’ button to start the experience</li>
  <ul>
<li>  <li>  LEFT and RIGHT arrows on the keyboard represent the respective Triggers</li>
UP and DOWN arrows control the left-controller-height, or pitch, for the Bells phase</li>
<li>‘d’ and ‘b’ keys represent the final choice for instrument infini-play</li>
<li>Move the mouse over the four corners to simulate up-and-down controller movement</li>
  </ul>


  
</ul>

