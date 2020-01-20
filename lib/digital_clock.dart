// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/services.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'controllers/dial_controller.dart';

class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;
  DialController _dialController;
  IconData _icon;

  bool _hasLoaded = false;
  final String darkLightAnimation = "dark->light";
  final String lightDarkAniamtion = "light->dark";
  final String flareFilePath = "assets/fl2.flr";
  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _dialController = DialController(() {
      //this function will execute once the DialController has been initialised
      _updateModel();
      setState(() {
        _hasLoaded = true;
      });
    });
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      _updateWeatherIcon(widget.model.weatherCondition);
      try {
        if (widget.model.is24HourFormat) {
          _dialController.showAmPmDial(false);
        } else {
          _dialController.showAmPmDial(true);
        }
        _timer?.cancel();
        print("Model update successful");

        _updateTime();
      } catch (e) {
        print(
            "Clock update after model change has failed: $e, attempting to reupdate!");
        Timer(Duration(seconds: 1), _updateModel);
      }
    });
  }

  /*Updaing the the time, runs every minute. */
  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      String hours;
      if (widget.model.is24HourFormat) {
        hours = DateFormat('HH').format(_dateTime);
      } else {
        hours = DateFormat('hh').format(_dateTime);
      }
      String minutes = DateFormat('mm').format(_dateTime);
      try {
        //updating the clocks features
        _dialController.setMinute(minutes);
        _dialController.setHours(hours, widget.model.is24HourFormat);
        _dialController.adjustBackground(hours, widget.model.is24HourFormat,
            DateFormat('aa').format(_dateTime));
        if (!widget.model.is24HourFormat) {
          _dialController.adjustAmPmDial(DateFormat('aa').format(_dateTime));
        }
        print("Clock has been updated successfully: ${_dateTime.toString()}");
      } catch (e) {
        //if the artboard has not been found or animation is not found, an exception will be caught here.
        print("Failed to update clock, attempting again in 1 second");
        _timer?.cancel(); //cancelling the timer that runs every minute
        Timer(Duration(seconds: 1),
            _updateTime); //executing this method after a second
        return;
      }
      _timer = Timer(
        Duration(minutes: 1) -
            Duration(seconds: _dateTime.second) -
            Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  /*Updating the weather icon on the clock face.  */
  void _updateWeatherIcon(WeatherCondition weatherCondition) {
    switch (weatherCondition) {
      case WeatherCondition.windy:
        _icon = MdiIcons.weatherWindy;
        break;
      case WeatherCondition.cloudy:
        _icon = MdiIcons.weatherCloudy;
        break;
      case WeatherCondition.foggy:
        _icon = MdiIcons.weatherFog;
        break;
      case WeatherCondition.rainy:
        _icon = MdiIcons.weatherRainy;
        break;
      case WeatherCondition.snowy:
        _icon = MdiIcons.weatherSnowyHeavy;
        break;
      case WeatherCondition.sunny:
        _icon = MdiIcons.weatherSunny;
        break;
      case WeatherCondition.thunderstorm:
        _icon = MdiIcons.weatherLightningRainy;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.black,
        child: Stack(
          children: <Widget>[
            !_hasLoaded
                ? Align(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(),
                  )
                : Container(),
            FlareActor(
              flareFilePath,
              animation: Theme.of(context).brightness == Brightness.light
                  ? darkLightAnimation
                  : lightDarkAniamtion,
              fit: BoxFit.cover,
              controller: _dialController,
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                  child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          _icon,
                          color: Colors.white,
                          size: 50.0,
                        ),
                        SizedBox(
                          width: 1.0,
                        ),
                        Flexible(
                          child: Text(widget.model.temperatureString,
                              style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 30.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    Text(
                      DateFormat('MMM. DD, yyyy').format(_dateTime),
                      style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 25.0,
                          color: Colors.white,
                          fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              )),
            ),
          ],
        ));
  }
}
