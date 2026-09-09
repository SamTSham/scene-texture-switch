# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'test_helper'
require_relative '../source/extension/scene_texture_switcher/library_association'

class LibraryAssociationTest < Minitest::Test
  Association = SamMadwar::SceneTextureSwitch::LibraryAssociation

  class FakeModel
    def initialize
      @attributes = {}
    end

    def get_attribute(dictionary, key, default)
      @attributes.fetch([dictionary, key], default)
    end

    def seed(dictionary, key, value)
      @attributes[[dictionary, key]] = value
    end
  end

  def test_reads_the_existing_folder_association
    model = FakeModel.new
    model.seed('SceneTextureSwitcher', 'texture_library_folder', 'Textures — Set')

    assert_equal 'Textures — Set', Association.folder_name(model)
  end

  def test_returns_nil_when_no_association_exists
    model = FakeModel.new

    assert_nil Association.folder_name(model)
  end

  def test_does_not_expose_unused_attribute_writers
    refute_respond_to Association, :set
    refute_respond_to Association, :clear
  end
end
