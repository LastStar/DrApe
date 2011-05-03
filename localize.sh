#!/bin/bash
cd BeatTheMonkey
ibtool --strings-file sk.lproj/FlipSideViewController.strings --write sk.lproj/FlipSideViewController.xib en.lproj/FlipSideViewController.xib
ibtool --strings-file cs.lproj/FlipSideViewController.strings --write cs.lproj/FlipSideViewController.xib en.lproj/FlipSideViewController.xib