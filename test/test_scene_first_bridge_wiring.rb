# frozen_string_literal: true

require 'minitest/autorun'

class SceneFirstBridgeWiringTest < Minitest::Test
  ROOT = File.expand_path('..', __dir__)

  def test_bridge_preserves_legacy_method_and_requires_explicit_association
    source = File.read(File.join(ROOT, 'source', 'extension', 'scene_texture_switcher', 'scene_first_bridge.rb'))

    assert_includes source, 'alias_method(LEGACY_METHOD, :apply_all_textures)'
    assert_includes source, 'preferred = LibraryAssociation.folder_name(model)'
    assert_includes source, 'TextureLibraryStatus.layout(discovery[:root]) == :scene_first'
    assert_includes source, 'public_send(SceneFirstBridge::LEGACY_METHOD, cue)'
  end
end
