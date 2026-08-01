# frozen_string_literal: true

require 'minitest/autorun'
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

    def set_attribute(dictionary, key, value)
      @attributes[[dictionary, key]] = value
    end

    def delete_attribute(dictionary, key)
      @attributes.delete([dictionary, key])
    end
  end

  def test_stores_only_a_folder_name_beside_the_model
    model = FakeModel.new

    assert_equal 'Textures — Set', Association.set(model, 'Textures — Set')
    assert_equal 'Textures — Set', Association.folder_name(model)
    assert_raises(ArgumentError) { Association.set(model, '../Elsewhere') }
  end

  def test_can_clear_association
    model = FakeModel.new
    Association.set(model, 'Textures — Set')

    Association.clear(model)

    assert_nil Association.folder_name(model)
  end
end
