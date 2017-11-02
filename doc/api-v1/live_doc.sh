#!/bin/bash
# Generate a live preview of the documentation on http://localhost:10000
aglio -s -p 10000 --theme-template triple --theme-variables streak --theme-style default --theme-style theme.less -i index.apib
