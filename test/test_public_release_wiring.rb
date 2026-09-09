# frozen_string_literal: true

require 'minitest/autorun'

class PublicReleaseWiringTest < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  BASENAME = 'sam_madwar_scene_texture_switch'

  def test_public_loader_has_identity_and_matching_folder_path
    source = File.read(File.join(ROOT, 'source', 'public', "#{BASENAME}.rb"))

    assert_includes source, 'module SamMadwar'
    assert_includes source, 'module SceneTextureSwitch'
    assert_includes source, "'#{BASENAME}/core'"
    assert_includes source, "EXTENSION.version = '1.0.1'"
    assert_includes source, "EXTENSION.creator = 'Sam Madwar'"
    assert_includes source, "EXTENSION.copyright = 'Copyright 2026 Sam Madwar'"
  end

  def test_public_builder_creates_only_matching_root_pair
    source = File.read(File.join(ROOT, 'tools', 'build_public_release.rb'))

    assert_includes source, "BASENAME = '#{BASENAME}'"
    assert_includes source, 'File.join(stage, BASENAME)'
    assert_includes source, '"#{BASENAME}.rb"'
    refute_includes source, 'SceneTextureOverviewPreview.rb'
    refute_includes source, '/Users/'
  end

  def test_shipped_runtime_uses_developer_namespace
    runtime_files = %w[
      namespace.rb texture_library_status.rb scene_snapshot.rb
      overview_pages_observer.rb scene_assignment.rb library_association.rb
      texture_applier.rb scene_marker_name.rb scene_marker_sync.rb
      preview_assets.rb surface_labels.rb scene_transition_observer.rb
    ]
    runtime_files.each do |name|
      source = File.read(File.join(ROOT, 'source', 'extension', 'scene_texture_switcher', name))
      refute_includes source, 'module SceneTextureSwitcher', name
    end

    controller = File.read(File.join(ROOT, 'source', 'overview_preview', 'scene_texture_overview_preview', 'core.rb'))
    assert_includes controller, 'module SamMadwar::SceneTextureSwitch'
  end

  def test_all_shipped_internal_loads_support_warehouse_encryption
    runtime_files = %w[
      namespace.rb texture_library_status.rb scene_snapshot.rb
      overview_pages_observer.rb scene_assignment.rb library_association.rb
      texture_applier.rb scene_marker_name.rb scene_marker_sync.rb
      preview_assets.rb surface_labels.rb scene_transition_observer.rb
    ].map { |name| File.join(ROOT, 'source', 'extension', 'scene_texture_switcher', name) }
    runtime_files << File.join(ROOT, 'source', 'overview_preview', 'scene_texture_overview_preview', 'core.rb')

    runtime_files.each do |path|
      source = File.read(path)
      refute_match(/(?<!Sketchup\.)require File\.join/, source, path)
    end
  end

  def test_startup_monitor_does_not_poll_or_apply_the_open_models_textures
    controller = File.read(File.join(ROOT, 'source', 'overview_preview', 'scene_texture_overview_preview', 'core.rb'))

    refute_includes controller, 'start_scene_safety_polling'
    refute_includes controller, 'UI.start_timer(1.0, true)'
    assert_includes controller, 'Sketchup::Pages.add_frame_change_observer'
  end

  def test_public_guide_uses_cross_platform_file_browser_wording
    guide = File.read(File.join(ROOT, 'docs', 'USER_GUIDE.md'))
    settings = File.read(File.join(ROOT, 'source', 'overview_preview', 'scene_texture_overview_preview', 'html', 'settings.html'))

    refute_match(/Finder/i, guide)
    refute_match(/Finder/i, settings)
    assert_match(/file-browser/i, guide)
    assert_match(/file-browser/i, settings)
  end

  def test_persistent_controller_uses_utility_palette_window
    controller = File.read(File.join(ROOT, 'source', 'overview_preview', 'scene_texture_overview_preview', 'core.rb'))

    main_dialog = controller[/@dialog = UI::HtmlDialog\.new\(\{.*?@dialog\.set_file/m]
    refute_nil main_dialog
    assert_includes main_dialog, 'UI::HtmlDialog::STYLE_UTILITY'

    settings_dialog = controller[/@settings_dialog = UI::HtmlDialog\.new\(\{.*?@settings_dialog\.set_file/m]
    refute_nil settings_dialog
    assert_includes settings_dialog, 'UI::HtmlDialog::STYLE_DIALOG'
  end
end
