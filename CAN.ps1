[CmdletBinding()]
Param()


# -L : Use log format for stdout. Useful for parsing
# Filters and docs:
#   https://wiki.linklayer.com/index.php/CAN_Filters
#   https://manpages.debian.org/testing/can-utils/candump.1.en.html
candump -L can0,421:7FF | ForEach {

	# Sample input: "(2602081823.869841) vcan0 421#080000"
	$Parts = $_ -split '\s+'
	$Data = $Parts[2]
	Write-Verbose ("{0}: Interface: {1} Data: {2}" -f (Get-Date), $Parts[1], $Parts[2])
	
	Switch -wildcard ($Data){
		# cansend can0 421#080000 && sleep 0.5 && systemctl status monitorCAN
		'421#08*' {
            Write-Verbose 'Reverse gear detected'
			$InReverse = $True

			# Wait 0.5 Seconds
			# if still in reverse, start display output
            # Thread-Job?
            #   Will it have access to parent scope?
            # Possible to query current value?
            If(!$ReverseCamera){
                $ReverseCamera = Start-ThreadJob {

                    Start-Sleep 0.5
                    Write-Verbose "Starting reverse camera display"
                    $Env:DISPLAY=':0'

                    # Ensure no other instances are running
                    killall cvlc && killall cvlc

                    # MACROSILICON UVC converter
            		$Param = @{
            		    FilePath = 'cvlc'
            		    ArgumentList = @(
                            '--fullscreen'
                            '--no-video-title-show'
                            #'v4l2:///dev/video0' # This index is not reliable if multiple cameras installed
                            'v4l2:///dev/v4l/by-id/usb-MACROSILICON_AV_TO_USB2.0_20150130-video-index0'
            		    )
            		    PassThru = $True
                    }
            		
                    Start-Process @Param
                    
                    #Somagic EasyCap 4ch
                    #killall mplayer && killall mplayer
                    #$Param = @{
                    #    FilePath = 'mplayer'
                    #    ArgumentList = @(
                    #	    '-vf yadif,screenshot'
                    #	    '-demuxer rawvideo'
                    #	    '-rawvideo "ntsc:format=uyvy:fps=30000/1001"'
                    #	    '-aspect 16:9'
                    #	    '- < /home/pi/ReverseCam'
                    #    )
                    #    PassThru = $True
                    #}
                    
                }
            }
			
		}
		'421#10*' {
			# Car in park
			# wait 1 second, stop any rearview display processes
			Write-Verbose "Parking gear detected"
			If($ReverseCamera){
			    Write-Verbose "Stopping reverse camera job"
		        $P = Receive-Job $ReverseCamera
		        If($P){ Stop-Process $P }
			    $P = $Null

			    $ReverseCamera | Stop-Job | Remove-Job
			    $ReverseCamera = $Null
			    Write-Verbose "Reverse camera job stopped"
			}
			
		}
	}

}


# Testing:
# sudo systemctl restart monitorCAN && sleep 3 && systemctl status monitorCAN
# cansend can0 421#080000 && sleep 0.5 && systemctl status monitorCAN
# systemctl status monitorCAN
# cansend can0 421#080000 && sleep 0.1 && cansend can0 421#100000 &&sleep 1 && systemctl status monitorCAN
#

