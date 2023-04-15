#!/bin/bash

# Global
name="vid_wall"

# Store the ids of windows with name 'Desktop — Plasma' in a list
window_ids=($(xwininfo -root -tree | grep 'Desktop' | awk '{ print $1 }'))
# Store length of list windows_ids in count
count=${#window_ids[@]}

_screen() {
	for (( i=0; i<$count; i++ ))
	do
    	mpv --input-ipc-server=/tmp/mpvsocket"$i" --no-osc --no-osd-bar --quiet --no-audio --screen=0 --wid="${window_ids[$i]}" --loop "$1" &
	done
}

# Help
print_help() {
    echo "Usage: ./$name.sh [--start] \"video_path.mp4\""
    echo ""
    echo "--start - Start playback of video file."
    echo ""
    echo "--pause - Pause active playback."
    echo ""
    echo "--resume - Resume paused playback."
    echo ""
    echo "--stop - Stop active playback."
    echo ""
}


# Parse command line options
while [[ $# -gt 0 ]]; do
    case "$1" in 
		--start)
			_screen "$2"
			exit 0
		;;

		--pause)
			for (( i=0; i<$count; i++ ))
			do
				echo '{ "command": ["set_property", "pause", true] }' | socat - /tmp/mpvsocket"$i"
			done
			exit 0
		;;

		--resume)
			for (( i=0; i<$count; i++ ))
			do
				echo '{ "command": ["set_property", "pause", false] }' | socat - /tmp/mpvsocket"$i"
			done
			exit 0
		;;

		--stop)
			for i in "${window_ids[@]}";
			do
				killall mpv
			done
			exit 2
		;;

		--*)
			print_help
			exit 1
		;;
	esac
done



