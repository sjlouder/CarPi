sudo ip link add type vcan
sudo ip link set vcan0 up type can


# TODO: add filters to candump for performance
candump vcan0 -L | ForEach {
	$Parts = $_ -split '\s+'
	#$Length = [Int] $Parts[3][1]	# Length value maxes out at 8
	#$ID = $Parts[2]
	#$Data = $Parts[4..($Length + 3)]
	# For testing
	"{0}: Interface: {1} Data: {2}" -f (Get-Date), $Parts[1], $Parts[2]
	
	# Sample input: "(2602081823.869841) vcan0 421#080000"
	$Data = ($_ -split '\s+')[2]
	
	Switch -wildcard ($Data){
		'421#08*' {
			# Car in reverse
			# Start rearview display process
			$ReverseJob = Start-Job {
				$Env:DISPLAY=':0'
				somagic-capture -n -i 1 |
					mplayer -vf yadif,screenshot -demuxer rawvideo -rawvideo "ntsc:format=uyvy:fps=30000/1001" -aspect 4:3 -
			}
			
		}
		'421#10*' {
			# Car in park
			# wait 1 second, stop any rearview display processes
		}
	}

}
