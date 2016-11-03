---
layout: post
title: Modding a Qisan 82-key Keyboard
date: 2016-08-21
---

Bill of materials
-----------------

-   [120 Gateron
    Clears](https://deskthority.net/wiki/Gateron_KS-3_series) from
    MassDrop  
-   Qisan board, disassembled (Plate, and Case)
-   82 1n4148 diodes that I had left over from previous projects  
-   a [Teensy 2.0](http://www.pjrc.com/teensy/index.html)  
-   Solder, associated tools, wiring

Original Board
--------------

This was the first mechanical keyboard that I ever purchased, a [Qisan
82-key from
Amazon](https://www.amazon.com/Qisan-Keyboard-Mechanical-Backlight-Cable-Black/dp/B01890YINM/).
I really enjoyed the typing experience, but the blue switches were, of
course, really loud.

I wasn't willing to put up with the Dell default that I had at work, so
I opted to purchase an inconspicuous Cherry 3.0. Still, I wanted to make
the Qisan do something for me.


Guides
------

[matt3o's
BrownFox](https://deskthority.net/workshop-f7/brownfox-step-by-step-t6050.html) 
inspired me to pursue this project, but I used a different approach because mine 
is an 82-key board and I already had some materials.

There's a lot of other stuff online for doing this sort of project.
[This reddit guide for building a keyboard from the ground up is pretty
helpful](https://www.reddit.com/r/MechanicalKeyboards/comments/4l0p41/guide_detailed_guide_to_making_a_custom_keyboard/),
though (like matt3o's guide) it goes beyond my needs.

Physically placing the switches and wires in the right places is easy
enough, but I needed a custom solution for firmware and wiring.  

As far as firmware, there's a lot of information available. [This is a
pretty good
guide](https://deskthority.net/workshop-f7/how-to-build-your-very-own-keyboard-firmware-t7177.html),
though I took an even easier approach.

Still, it's nice to learn about what's going on. [This site has a good
description of some theory behind keyboard
matrices](http://blog.komar.be/how-to-make-a-keyboard-the-matrix/), and
[this site does,
too](http://pcbheaven.com/wikipages/How_Key_Matrices_Works/).

Choosing a microcontroller
--------------------------

After reading through some guides, I chose the Teensy 2.0 because it is
small and has enough pins for my needs. I picked up a Teensy++ 2.0, too,
just in case I broke the first one or wanted to pursue a new project
later.

The Teensy 2.0 uses an Atmega32U4 processor, and it is stupidly (I mean
that in a good way) easy to program. The workflow for reprogramming the
Teensy is:

1.  Open the "Teensy Loader Application"  
2.  Push the single button that is present on the Teensy  
3.  Open the hex file that contains instructions
4.  Reboot the Teensy

I've never used a microcontroller, and have generally limited myself to
processing analog signals (from my guitar). I can set up a couple of
transistors to make my guitar sound fuzzy, but I've never designed
software for a processor. This is a whole new world for me.

Building the matrix and its firmware
------------------------------------

Fortunately, the process of programming a keyboard can be done with
(almost) entirely GUI interfaces.

I used the Keycool 84 present [from
keyboard-layout-editor.com](http://www.keyboard-layout-editor.com/),
modifying it for my needs. I ended up with [this
layout](http://www.mustafa.fyi/assets/qisan_keyboard_layout.json).

I then dropped the json file into [Ruiqi Mao's](http://reddit.com/u/iandr0idos)
[TMK Firmware Builder](http://kb.sized.io/), which showed me how to wire
the matrix.

The firmware builder has a GUI for picking the keys that I'd like for
seven different layers, but I only took advantage of a couple layers. I
set it up so that there is a numpad in layer one, as well as arrow keys
on either side of the board in layer one. The json should explain it
all.

The Firmware Builder lets you compile in-browser, so that you can
download a hex file to upload to the Teensy 2.0.

Honestly, doing it this way felt like cheating. I browsed the source
code a little bit, and it made sense given the theory that was presented
in previous links. Still, I kinda wish I was forced to write out my own
code. On the other hand, I'm not going to rebuild the wheel unless it's
an academic exercise.

Doing it.
---------

[Here's a picture of the fully-wired board, with the Teensy, Matrix, and
all](http://www.mustafa.fyi/assets/qisan_matrix.JPG)

Because the Qisan comes with a plastic case, [I was able to cut it up to
access the
Teensy.](http://www.mustafa.fyi/assets/qisan_teensy_access.JPG) This
isn't pretty, but it also works.

Unfortunately, I don't have proper keycaps, so [the board is a bit of a
frankenstein.](http://www.mustafa.fyi/assets/qisan_frankenstein.JPG).
This is okay, for now.

Future directions
-----------------

[This website](http://builder.swillkb.com/) generates the CAD files
necessary to build a keyboard with whatever layout you'd like. I'm not
sure if I'll do that, but it's nice to know the option is there.

I'll probably be programming and reprogramming the board to suit my
liking. I love having this control over the keys available to me,
especially with the opportunity to mess around with the source to see
what happens.

Maybe, just maybe, I'll look into a 60% keyboard. The 82 keys are
plentiful, perhaps even copious. Hopefully, I'll update if I do work on
a 60% board.
