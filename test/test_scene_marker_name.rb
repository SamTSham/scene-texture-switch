# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../source/extension/scene_texture_switcher/scene_marker_name'

class SceneMarkerNameTest < Minitest::Test
  Naming = SamMadwar::SceneTextureSwitch::SceneMarkerName

  def test_plain_name_is_unchanged
    assert_equal 'Opening', Naming.sanitize('Opening')
  end

  def test_slashes_do_not_create_nested_paths
    assert_equal 'Kitchen - Evening', Naming.sanitize('Kitchen / Evening')
    assert_equal 'Act 1 - Scene 4', Naming.sanitize('Act 1\\Scene 4')
  end

  def test_wildcards_and_reserved_characters_are_literal_and_safe
    assert_equal 'Scene all versions', Naming.sanitize('Scene:*?all|versions')
  end

  def test_empty_or_dot_only_names_get_a_fallback
    assert_equal 'Untitled Scene', Naming.sanitize('...')
    assert_equal 'Untitled Scene', Naming.sanitize(" \t ")
  end

  def test_windows_reserved_names_are_protected
    assert_equal '_CON', Naming.sanitize('CON')
    assert_equal '_LPT1.txt', Naming.sanitize('LPT1.txt')
  end

  def test_duplicates_get_stable_point_suffixes
    assert_equal %w[Kitchen Kitchen.2 Kitchen.3],
                 Naming.allocate(%w[Kitchen Kitchen Kitchen])
  end

  def test_duplicate_comparison_is_case_insensitive
    assert_equal ['Kitchen', 'kitchen.2'], Naming.allocate(['Kitchen', 'kitchen'])
  end

  def test_next_available_does_not_fill_an_occupied_suffix
    occupied = ['Kitchen', 'Kitchen.2', 'Kitchen.4']
    assert_equal 'Kitchen.3', Naming.next_available('Kitchen', occupied)
  end

  def test_name_length_is_limited
    assert_equal 120, Naming.sanitize('a' * 200).length
    assert_operator Naming.allocate(['a' * 200, 'a' * 200]).last.length, :<=, 120
  end
end

