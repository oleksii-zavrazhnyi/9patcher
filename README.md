9patcher
========

Automatic nine-patch tool that crops central part of image (buttons, inputs, backgrounds)

Installation
========
```bash
git clone git@github.com:TheMengzor/9patcher.git
cd 9patcher
sudo ln 9pather.sh /usr/bin/9patcher.sh
```

Usage
========
Patch single file
```bash
9patch.sh file
```
Patch several files
```bash
9patch.sh file1 file2 ... fileN
```
Patch files by the mask (in this case all **.png** files)
```bash
9patch.sh *.png
```
**Most useful!** Patch all files which names starts with **button_**
```bash
9patch.sh button_*
```
