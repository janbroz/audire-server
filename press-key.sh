#!/bin/bash
sonic-pi-tool eval-file /home/pan/giskards-positronic-brain/visual-classifier/sonicpi/$1.rb & sonic-pi-tool record $1.wav & (sleep 10 ; echo -ne '\n' ; xdotool key Return & sonic-pi-tool stop ; sleep 1)
echo "Done"
