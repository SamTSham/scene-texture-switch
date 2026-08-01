# frozen_string_literal: true

require 'sketchup.rb'

# Retirement shim: installing the unified release overwrites the former
# development companion loader so it no longer registers duplicate menus.
file_loaded(__FILE__) unless file_loaded?(__FILE__)
