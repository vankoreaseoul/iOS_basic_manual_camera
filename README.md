## iOS_manual_camera

### Intoroduction
This is a sort of mini or toy project about controlling camera.
On the meeting in company, we're thinking of new function to be added on the on-service app.
The selected new idea is about analyzing images and for that, I need to be prepared to controlling camera fully.
The built-in-camera on iPhone is already good enough, cause it automatically adjusts focus, exposure and etc, but that's not what I want.
I want to controll camera manually as I want, not automatically. 
So I find and learn how to control camera focus, exposure and white balance.
Hope it can help you guys!

### Feature
- SwiftUI
- AVFoundation

### Attentions
1. Check your camera type before starting the project.
- The built-in-camera type is different depending on iPhone models. So please check if the selected camera type on code is supported on your iPhone model. And you need to recognize that the manual controlling is supported in cerain camera types.
2. Remind of range on ISO(in exposure) and RGB(white balance).
- If the value is over the range, the exception occurs. You would be able to understand what I mean on code. You can customize values on code but be careful not to over the range. Keep in mind that some values have a range.
3. Can't control f-stop.
-  Maybe you're searching for adjusting f-stop? I also did. But on Apple document, you would see that you just can get the value(Get-Only). Each lens has its own f-stop value so you can see the f-stop value changes by camera type you selected.
4. Adjust exposure values if you can't see anything, just dark screen
- If you can't see the warning text, the camera works well. But sometimes if the environment around you is a bit dark, you can see just the black screen. It's because that the default value of exposure is the minium. So adjust it to the higer value, then you can see the image.
