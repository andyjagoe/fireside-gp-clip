# fireside-gp-clip
Extract video clips from GoPro footage. Set original recorded date and enable adding GPS metadata to clip. For use in services like [Fireside](http://www.fireside.co).

This script is written for Mac and was tested on Mac OS X Yosemite 10.10.4. It requires [avmetareadwrite](https://developer.apple.com/library/mac/samplecode/avmetadataeditor/Listings/ReadMe_txt.html) (via Apple's Xcode Command Line Tools) and [avconv](https://libav.org/) be installed with support for h264/MP4.

### Install Instructions for avmetareadwrite

* Install Xcode and Xcode command line tools: https://developer.apple.com/xcode/download/
* avmetareadwrite will be available once Xcode command line tools are correctly installed.

### Install Instructions for avconv

* Install the Brew package manager: http://brew.sh/
* Install avconv via brew

```brew install libav```
