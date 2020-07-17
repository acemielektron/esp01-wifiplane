# esp01-wifiplane

Here is the modified code and hardware for esp01 running [RAVI_BUTANI](https://www.instructables.com/member/RAVI_BUTANI/)'s cheapest diy [WIFI-CONTROLLED-RC-PLANE](https://www.instructables.com/id/WIFI-CONTROLLED-RC-PLANE/).

**Highlights**

* Hardware: Works on esp01's gpio0 and gpio2, both bootstrap pins require pullup on boot, so output is inverted

* Arduino code: Ability to invert outputs and switch gpio pins using define directives

* Android code: Now also works in home networks (for testing). A [compiled binary](ProcessingAndroidApp/wifiplane.apk) is supplied if you dont want to install processing and android sdk.
