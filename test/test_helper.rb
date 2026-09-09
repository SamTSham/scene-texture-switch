# frozen_string_literal: true

# Production uses Sketchup.require so encrypted .rbe files load correctly.
# Outside SketchUp, tests delegate that API to Ruby's loader.
module Sketchup
  def self.require(path)
    Kernel.require(path)
  end
end
