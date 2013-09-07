9patcher
========

Automatic nine-patch tool that crops central part of image (buttons, inputs, backgrounds).

![9patcher](http://themengzor.com/9patcher.png)

Easy in use: central 2 pixels will be stretchable.

Written in bash. Tested only on OS X 10.8.4

If you can test it on different systems, please feedback me with results on me@themengzor.com

Requirements
========
* BASH
* Standard UNIX tools: **mktemp**
* ImageMagick: **identify**, **convert** and **montage** binaries

Installation
========
```bash
git clone git@github.com:TheMengzor/9patcher.git
cd 9patcher
chmod +x ./9patcher.sh
sudo ln 9pather /usr/bin/9patcher.sh
```

Usage
========
Patch single file
```bash
9patch file
```
Patch several files
```bash
9patch file1 file2 ... fileN
```
Patch files by the mask (in this case all **.png** files)
```bash
9patch *.png
```
**Most useful!** Patch all files which names starts with **button_**
```bash
9patch button_*
```
Skip 40 pixels on the left (see example image with facebook buttons). Note that 40 is just an example, you can use any number in -skip parameter
```bash
9patch -skip 40 ./btn_facebook@2x.png
```
