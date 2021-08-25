#Source: https://gpiozero.readthedocs.io/en/stable/recipes.html#shutdown-button

from gpiozero import Button
from subprocess import check_call
from signal import pause
import logging

def shutdown():
    logging.warning('Button hold detected. Initiating shutdown')
    check_call(['sudo', 'poweroff'])

button = Button(21, hold_time=5)
button.when_held = shutdown

# If for some reason the accessory power is killed after the computer boots
# but before the service is started, the shutoff relay timer will be counting
# down, but the when_held won't trigger if the button is created while it's low.
# So check on start and 
if button.is_pressed:
    logging.warning('Accessory power not detected on startup')
    if not button.wait_for_release(5):
        shutdown()

logging.warning('Monitoring')
pause()