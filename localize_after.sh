#!/bin/bash

cd BeatTheMonkey

ibtool --strings-file en.lproj/FlipSideViewController.xib.strings --write en.lproj/FlipSideViewController.xib en.lproj/FlipSideViewController.xib
ibtool --strings-file cs.lproj/FlipSideViewController.xib.strings --write cs.lproj/FlipSideViewController.xib en.lproj/FlipSideViewController.xib
ibtool --strings-file sk.lproj/FlipSideViewController.xib.strings --write sk.lproj/FlipSideViewController.xib en.lproj/FlipSideViewController.xib
