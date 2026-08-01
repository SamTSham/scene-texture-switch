# frozen_string_literal: true

module SceneTextureSwitcher
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
