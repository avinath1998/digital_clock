import 'dart:async';
import 'dart:math';

import 'package:digital_clock/exceptions/animation_not%20_initialized_exception.dart';
import 'package:digital_clock/exceptions/animation_not_found_exception.dart';
import 'package:flare_dart/math/mat2d.dart';
import 'package:flare_flutter/flare.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controller.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/material.dart';

class DialController extends FlareController {
  DialController(this.initializationCallback);

  final String animationEventingToNight = "bg-evening->night";
  final String animationMorningToAfternoon = "bg-morning->afternoon";
  final String animationNightToMorning = "bg-night->morning";
  final String animationAfternoonToEveing = "bg-afternoon->evening";
  final String animationAmToPm = "am->pm";
  final String animationPmToAm = "pm->am";
  final String animationHideAmPm = "hide-am-pm";
  final String animationShowAmPm = "show-am-pm";
  final String animationLightToDark = "light->dark";
  final String animationDarkToLight = "dark->light";

  FlutterActorArtboard _artboard;
  final List<FlareAnimationLayer> _baseAnimations = [];

  int _fourthDialValue;
  int _thirdDialValue;
  int _secondDialValue;
  int _firstDialValue;

  bool _isAm = true;
  bool _isAmPmDialVisible = true;
  BackgroundState _currentBackgroundState = BackgroundState.night;
  Function() initializationCallback;
  ColorTheme _currentColorTheme = ColorTheme.light;

  @override
  bool advance(FlutterActorArtboard artboard, double elapsed) {
    int len = _baseAnimations.length - 1;
    for (int i = len; i >= 0; i--) {
      FlareAnimationLayer layer = _baseAnimations[i];
      layer.time += elapsed;
      layer.mix = min(1.0, layer.time / 0.01);
      layer.apply(_artboard);
      if (layer.isDone) {
        _baseAnimations.removeAt(i);
      }
    }
    return true;
  }

  @override
  void initialize(FlutterActorArtboard artboard) {
    _artboard = artboard;
    print("Dial Controller Has Been Initialized");
    initializationCallback();
  }

  void setColorTheme(ColorTheme theme) {
    if (theme != _currentColorTheme) {
      if (theme == ColorTheme.dark) {
        _addAnimationToBuffer(animationLightToDark);
      } else {
        if (theme != _currentColorTheme)
          _addAnimationToBuffer(animationDarkToLight);
      }
    }
    _currentColorTheme = theme;
  }

  void adjustBackground(String hour, bool is24Hr, String amPm) {
    int hours = int.parse(hour);
    if (is24Hr) {
      if (hours >= 19 || hours <= 6)
        _adjustBackgroundState(BackgroundState.night);
      else if (hours <= 11 && hours >= 7)
        _adjustBackgroundState(BackgroundState.morning);
      else if (hours <= 16 && hours >= 12)
        _adjustBackgroundState(BackgroundState.afternoon);
      else if (hours <= 18 && hours >= 17)
        _adjustBackgroundState(BackgroundState.evening);
    } else {
      if (amPm == "AM") {
        if (hours == 12 || hours <= 6) {
          _adjustBackgroundState(BackgroundState.night);
        } else if (hours >= 7 && hours <= 11) {
          _adjustBackgroundState(BackgroundState.morning);
        }
      } else if (amPm == "PM") {
        print(hours);
        if (hours == 12 || hours <= 4) {
          _adjustBackgroundState(BackgroundState.afternoon);
        } else if (hours >= 5 && hours <= 6) {
          _adjustBackgroundState(BackgroundState.evening);
        } else if (hours >= 7 && hours <= 11) {
          _adjustBackgroundState(BackgroundState.night);
        }
      }
    }
  }

  void _adjustBackgroundState(BackgroundState state) {
    if (_currentBackgroundState != state) {
      _currentBackgroundState = state;
      switch (state) {
        case BackgroundState.night:
          _addAnimationToBuffer(animationEventingToNight);
          break;
        case BackgroundState.afternoon:
          _addAnimationToBuffer(animationMorningToAfternoon);
          break;
        case BackgroundState.morning:
          _addAnimationToBuffer(animationNightToMorning);
          break;
        case BackgroundState.evening:
          _addAnimationToBuffer(animationAfternoonToEveing);
          break;
      }
    }
  }

  void adjustAmPmDial(String val) {
    if (val == "PM") {
      if (_isAm) {
        _addAnimationToBuffer(animationAmToPm);
        _isAm = false;
      }
    } else {
      if (!_isAm) {
        _addAnimationToBuffer(animationPmToAm);
        _isAm = true;
      }
    }
  }

  void showAmPmDial(bool val) {
    if (!val) {
      if (_isAmPmDialVisible) {
        _addAnimationToBuffer(animationHideAmPm);
        _isAmPmDialVisible = false;
      }
    } else {
      if (!_isAmPmDialVisible) {
        _addAnimationToBuffer(animationShowAmPm);
        _isAmPmDialVisible = true;
      }
    }
  }

  void setHours(String hour, bool is24Hr) {
    int firstVal = int.parse(hour.substring(0, 1));
    int secondVal = int.parse(hour.substring(1));
    String _secondDialAnimation;
    String _firstDialAnimation;
    if (firstVal != _firstDialValue) {
      _firstDialValue = firstVal;
      switch (firstVal) {
        case 1:
          _firstDialAnimation = "hour_long-0->1";
          break;
        case 2:
          _firstDialAnimation = "hour_long-1->2";
          break;
        case 0:
          if (is24Hr) {
            _firstDialAnimation = "hour_long-2->0";
          } else {
            _firstDialAnimation = "hour_long-1->0";
          }
          break;
      }
      _addAnimationToBuffer(_firstDialAnimation);
    }

    if (secondVal != _secondDialValue) {
      _secondDialValue = secondVal;
      switch (secondVal) {
        case 1:
          _secondDialAnimation = "hour_short-0->1";
          break;
        case 2:
          _secondDialAnimation = "hour_short-1->2";
          break;
        case 3:
          _secondDialAnimation = "hour_short-2->3";
          break;
        case 4:
          _secondDialAnimation = "hour_short-3->4";
          break;
        case 5:
          _secondDialAnimation = "hour_short-4->5";
          break;
        case 6:
          _secondDialAnimation = "hour_short-5->6";
          break;
        case 7:
          _secondDialAnimation = "hour_short-6->7";
          break;
        case 8:
          _secondDialAnimation = "hour_short-7->8";
          break;
        case 9:
          _secondDialAnimation = "hour_short-8->9";
          break;
        case 0:
          _secondDialAnimation = "hour_short-9->0";
          break;
      }
      _addAnimationToBuffer(_secondDialAnimation);
    }
  }

  void setMinute(String minute) {
    if (_artboard != null) {
      int firstVal = int.parse(minute.substring(0, 1));
      int secondVal = int.parse(minute.substring(1));
      String _fourthDialAnimation;
      String _thirdDialAnimation;
      if (firstVal != _thirdDialValue) {
        _thirdDialValue = firstVal;
        switch (firstVal) {
          case 1:
            _thirdDialAnimation = "minutes-0->1";
            break;
          case 2:
            _thirdDialAnimation = "minutes-1->2";
            break;
          case 3:
            _thirdDialAnimation = "minutes-2->3";
            break;
          case 4:
            _thirdDialAnimation = "minutes-3->4";
            break;
          case 5:
            _thirdDialAnimation = "minutes-4->5";
            break;
          case 0:
            _thirdDialAnimation = "minutes-5->0";
            break;
        }
        _addAnimationToBuffer(_thirdDialAnimation);
      }

      if (secondVal != _fourthDialValue) {
        _fourthDialValue = secondVal;
        switch (secondVal) {
          case 1:
            _fourthDialAnimation = "seconds-0->1";
            break;
          case 2:
            _fourthDialAnimation = "seconds-1->2";
            break;
          case 3:
            _fourthDialAnimation = "seconds-2->3";
            break;
          case 4:
            _fourthDialAnimation = "seconds-3->4";
            break;
          case 5:
            _fourthDialAnimation = "seconds-4->5";
            break;
          case 6:
            _fourthDialAnimation = "seconds-5->6";
            break;
          case 7:
            _fourthDialAnimation = "seconds-6->7";
            break;
          case 8:
            _fourthDialAnimation = "seconds-7->8";
            break;
          case 9:
            _fourthDialAnimation = "seconds-8->9";
            break;
          case 0:
            _fourthDialAnimation = "seconds-9->0";
            break;
        }
        _addAnimationToBuffer(_fourthDialAnimation);
      }
    } else {
      throw ArtboardNotInitializedException("Artboard not found");
    }
  }

  void _addAnimationToBuffer(String animationName) {
    if (_artboard != null) {
      ActorAnimation animation = _artboard.getAnimation(animationName);
      if (animation == null) {
        throw AnimationNotFoundException("Animation Not Found in Artboard!");
      }
      print(animation.name);
      _baseAnimations.add(FlareAnimationLayer()
        ..name = animationName
        ..animation = animation);
    } else {
      throw ArtboardNotInitializedException(
          "Cannot add to animation buffer, artboard not found");
    }
  }

  @override
  void setViewTransform(Mat2D viewTransform) {}
}

enum BackgroundState { night, afternoon, morning, evening }

enum ColorTheme { dark, light }
