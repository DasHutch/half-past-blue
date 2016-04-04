# Half-Past-Blue

Implementation of 'Color Clock' in Swift 2.0
Goal of this is to just build a simple universal app (iPhone, iPad) including mutlitasking for iPad
and maybe a Apple Watch app as well. Instead of using Hexadecimal colors from time, I'll be using HSB.
Looking at using the Hours to cycle through the Hue, Minutes to Adjust Brightness, and Seconds to cycle through Saturation...

Digital Clock Face and Analog Clock Face, with simple interaction reveal the color information for a given time.

## TODO:
-[x] Analog Clock Face
-[x] Add Setting for Fading Clock out & Reveal every 5 mins
-[x] Setting in Settings app to switch to using Hexadecimal Colors vs HSB Colors
-[ ] ~~Double Tap to change clock face~~
-[ ] ~~Single Tap 'bounce' like an Alert to educate on swapping clock faces~~ Currently, using simple page controller, UI
-[ ] Update UI for better clock face changing
-[ ] UI for displaying Color info at a given time
-[x] ColorManager Class for handling color choices from a NSDate
-[x] Use MonoSpace font
-[ ] Use Custom MonoSpace Font
-[x] Hide Status Bar
-[x] Create Clock Model (refactor)
-[ ] Write UI Tests
-[ ] Write Unit Tests
