# frozen_string_literal: true

Sketchup.require File.join(__dir__.dup.force_encoding(Encoding::UTF_8), 'namespace') unless defined?(SamMadwar::SceneTextureSwitch)

module SamMadwar::SceneTextureSwitch
  # SketchUp calls this object for every frame of a scene transition. We notify
  # the controller only once, at the first frame aimed at a new destination.
  class SceneTransitionObserver
    def initialize(owner)
      @owner = owner
      @destination = nil
    end

    def frameChange(_from_scene, to_scene, _percent_done)
      return unless to_scene
      return if to_scene.equal?(@destination)

      @destination = to_scene
      @owner.on_scene_transition_started(to_scene)
    end
  end
end
