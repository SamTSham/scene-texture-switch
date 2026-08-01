# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../source/extension/scene_texture_switcher/scene_transition_observer'

class SceneTransitionObserverTest < Minitest::Test
  Scene = Struct.new(:name)

  class Owner
    attr_reader :destinations

    def initialize
      @destinations = []
    end

    def on_scene_transition_started(scene)
      @destinations << scene
    end
  end

  def setup
    @owner = Owner.new
    @observer = SamMadwar::SceneTextureSwitch::SceneTransitionObserver.new(@owner)
  end

  def test_notifies_at_first_frame_only_during_a_long_transition
    destination = Scene.new('Twenty second scene')

    @observer.frameChange(nil, destination, 0.0)
    @observer.frameChange(nil, destination, 0.25)
    @observer.frameChange(nil, destination, 0.75)
    @observer.frameChange(nil, destination, 1.0)

    assert_equal [destination], @owner.destinations
  end

  def test_distinguishes_different_scene_objects_with_duplicate_names
    first = Scene.new('Duplicate')
    second = Scene.new('Duplicate')

    @observer.frameChange(nil, first, 0.0)
    @observer.frameChange(first, second, 0.0)

    assert_equal [first, second], @owner.destinations
  end

  def test_can_return_to_an_earlier_destination
    first = Scene.new('First')
    second = Scene.new('Second')

    @observer.frameChange(nil, first, 0.0)
    @observer.frameChange(first, second, 0.0)
    @observer.frameChange(second, first, 0.0)

    assert_equal [first, second, first], @owner.destinations
  end
end
