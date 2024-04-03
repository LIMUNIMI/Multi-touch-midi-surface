# Multi-touch-midi-surface
A DIY capacitive multi-touch midi instrument, protoyped as a bachelor final essay by Shawn Pinciara.
The project is based on [the work](https://hci.cs.uni-saarland.de/projects/multi-touch-kit/) of Narjes Pourjafarian, Anusha Withana, Joseph A. Paradiso and Jürgen Steimle.
![The multi-touch surface](/Src/arduino_mega_surface.jpg)

# Tutorial:
## How to:

**A detailed tutorial on making a surface with Arduino UNO can be found [here](https://github.com/HCI-Lab-Saarland/MultiTouchKitDoc/blob/master/MTK_Tutorial.pdf).**

The other pieces of software to be installed are:

- Processing MIDI library ([themidibus](https://github.com/sparks/themidibus))
- MIDI virtual ports ([LoopMIDI](https://www.tobias-erichsen.de/software/loopmidi.html))

Instead of using the Processing file cited in the tutorial, the file *Processing/MTK_MIDI/MTK_MIDI.pde* should be used instead.

## Structure:

The BlobMidi class handles the convertion from Blobs object (of the MultiTouchKit library) to MIDI events.

It is instantiated at setup() and his update() function called during the loop(), when the blob object (corresponding to the fingers’ touch) becomes non-null.

The update() function handles the blob in the 3 states:

- At push
    - Usually sends a NoteOn
- At hold
    - Usually sends a CC
- At release
    - Usually sends a NoteOff

All the states are debounced.

To offer more customization for different use cases these capabilities are offered:

- Discrete Map functions: to convert X,Y of the blobs not array indexes of MIDI notes (mapToInt() )
- Modes: the variable *mode* let the user program different MIDI convertions to handle the different use cases and mapping (standard modes are 0 = drum , 1 = piano , 3 = pentatonic scale)
- Log: all data can be recorded on tables and saved as CSV on mouse click or finger release
