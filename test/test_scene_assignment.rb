# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../source/extension/scene_texture_switcher/texture_library_status'
require_relative '../source/extension/scene_texture_switcher/scene_assignment'

class SceneAssignmentTest < Minitest::Test
  Assignment = SamMadwar::SceneTextureSwitch::SceneAssignment

  FakePage = Struct.new(:name, :persistent_id, :cue) do
    def set_attribute(_dictionary, _key, value)
      self.cue = value
    end
  end

  class FakePages < Array
    attr_accessor :selected_page
  end

  class FakeModel
    attr_reader :pages, :operations

    def initialize(pages)
      @pages = pages
      @operations = []
    end

    def start_operation(name, transparent)
      @operations << [:start, name, transparent]
    end

    def commit_operation
      @operations << [:commit]
    end

    def abort_operation
      @operations << [:abort]
    end
  end

  def test_assigns_any_scene_without_changing_the_selected_scene
    opening = FakePage.new('Opening', 101, '01')
    finale = FakePage.new('Finale', 102, '02')
    pages = FakePages.new([opening, finale])
    pages.selected_page = opening
    model = FakeModel.new(pages)

    result = Assignment.assign(model, 'page-102', '7')

    assert result[:success]
    assert_equal '07', finale.cue
    assert_equal opening, pages.selected_page
    refute result[:current]
    assert_equal [[:start, 'Assign Scene Texture', true], [:commit]], model.operations
  end

  def test_reports_current_scene_for_immediate_texture_application
    page = FakePage.new('Opening', 101, '01')
    pages = FakePages.new([page])
    pages.selected_page = page
    model = FakeModel.new(pages)

    result = Assignment.assign(model, 'page-101', '03')

    assert result[:success]
    assert result[:current]
  end

  def test_missing_scene_does_not_open_an_operation
    pages = FakePages.new([])
    model = FakeModel.new(pages)

    result = Assignment.assign(model, 'page-999', '03')

    refute result[:success]
    assert_empty model.operations
  end
end
