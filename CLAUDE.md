# Overall system design:
We will convert this flutter app into an app that communicates with a device that senses environmental and body temperature. Also, Sends an alert when temperature and sweat levels (in %RH) crosses a certain threshold. The temperature threshold is 98F sweat level threshold is 90 %rh. 

The app will be both iOS and android compatible. So, it needs to use Bluetooth Low Energy to communicate with the Arduino micro  AtMega32U4 device via bluetooth. It should also be able to send notifications to users for:
1. When temperature level rises above the given threshold
2. When sweat level rises above  the given threshold

# UI
For the UI, we will use the React code in the react.jsx file.

# Backend
The app will calculate if the input values (which are temperature and sweat level) have crossed the threshold value and will decide to send a notification to the user if the threshold values are crossed.