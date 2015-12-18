# fireside-gp-clip
Extract video clips from GoPro footage. Set original recorded date and enable adding GPS metadata to clip. For use in services like [Fireside](http://www.fireside.co).

This script is written for Mac and was tested on Mac OS X Yosemite 10.10.4. It requires [avmetareadwrite](https://developer.apple.com/library/mac/samplecode/avmetadataeditor/Listings/ReadMe_txt.html) (via Apple's Xcode Command Line Tools) and [avconv](https://libav.org/) be installed with support for h264/MP4.

### How gp-clip works

gp-clip takes your original GoPro footage and enables you to easily capture a snippet from it while preserving the original recorded date and allowing you to add GPS metadata to your clip.

By default, GoPro clips do not store recorded data--only encoded date and tagged date. Any edit or update of your video file and the opportunity to save the original recorded date will be lost since most editing software (including GoPro's as of now) will update the encoded and tagged date with the edited date.

gp-clip wraps the MP4 file with a quicktime MOV container and sets the original recorded date as the encoded date. If --start and  --time are specified, it will cut the file beginning at "start" for length "time". If latitude and longitude are specified, it will also set GPS metadata for the file using the com.apple.quicktime.location.ISO6709 key (the same way an iPhone geotags videos). Altitude is optional, and if included will also be set.   

gp-clip does not modify original files in any way. It makes a new file and cleans up all working copies used in the process. 

### Installing gp-clip

* Copy gp-clip.sh and template.plist into the directory containing your GoPro files.
* Make sure gp-clip.sh has execute privileges and can be run. ```sudo chmod +x gp-clip.sh```

### Installing avmetareadwrite

* Install Xcode and Xcode command line tools: https://developer.apple.com/xcode/download/
* avmetareadwrite will be available once Xcode command line tools are correctly installed.

### Installing avconv

* Install the Brew package manager: http://brew.sh/
* Install avconv via brew

```brew install libav```

### Using gp-clip

To generate a clip without adding GPS data to it, run from the command line:
 
```./gp-clip.sh -s HH:MM:SS -t HH:MM:SS FILENAME```

The -s or --start option specifies the point in time to start your clip. The -t or --time option specifies how long the clip should be. Both options use a zero padded time string where hours, minutes and seconds are separated by colon. For example, 00:01:30 is 1 minute 30 seconds. 00:00:45 is 45 seconds.

