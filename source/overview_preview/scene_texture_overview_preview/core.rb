# frozen_string_literal: true

require 'json'
require File.join(__dir__, 'texture_library_status')
require File.join(__dir__, 'scene_snapshot')
require File.join(__dir__, 'overview_pages_observer')
require File.join(__dir__, 'scene_assignment')
require File.join(__dir__, 'library_association')
require File.join(__dir__, 'texture_applier')
require File.join(__dir__, 'scene_first_bridge')
require File.join(__dir__, 'scene_marker_name')
require File.join(__dir__, 'scene_marker_sync')
require File.join(__dir__, 'legacy_library_scanner')
require File.join(__dir__, 'migration_planner')
require File.join(__dir__, 'verified_scene_first_migration')

module SceneTextureSwitcher
  # Standalone development companion for the guarded migration and editor.
  module OverviewPreview
    extend self

    def activate
      SceneFirstBridge.install
      if @dialog && @dialog.visible?
        @dialog.bring_to_front
        refresh(@dialog)
        return
      end

      @dialog = UI::HtmlDialog.new({
        :dialog_title => 'Scene Textures — Development',
        :preferences_key => 'SceneTextureOverviewPreview',
        :scrollable => false,
        :resizable => true,
        :width => 360,
        :height => 420,
        :min_width => 300,
        :min_height => 180,
        :style => UI::HtmlDialog::STYLE_DIALOG
      })
      @dialog.set_file(File.join(__dir__, 'html', 'overview.html'))
      @dialog.add_action_callback('requestSnapshot') do |_action_context|
        refresh(@dialog)
      end
      @dialog.add_action_callback('reloadCurrent') do |_action_context|
        reload_current_scene_textures
      end
      @dialog.add_action_callback('setCue') do |_action_context, scene_key, cue|
        assign_cue(scene_key, cue)
      end
      @dialog.add_action_callback('activateScene') do |_action_context, scene_key|
        activate_scene(scene_key)
      end
      @dialog.set_on_closed do
        detach_pages_observer
        @dialog = nil
      end
      @dialog.show
      attach_pages_observer
      sync_scene_markers
    end

    def refresh(dialog = @dialog)
      return unless dialog

      model = Sketchup.active_model
      project_dir = model.path.to_s.empty? ? nil : File.dirname(model.path)
      preferred = LibraryAssociation.folder_name(model)
      discovery = TextureLibraryStatus.discover(project_dir, preferred)
      snapshot = SceneSnapshot.build(model, discovery)
      dialog.execute_script("SceneTextureOverview.render(#{JSON.generate(snapshot)})")
    rescue StandardError => error
      puts "[SceneTextureOverviewPreview] Refresh failed: #{error.class}: #{error.message}"
    end

    def assign_cue(scene_key, cue)
      result = SceneAssignment.assign(Sketchup.active_model, scene_key, cue)
      unless result[:success]
        UI.messagebox("Texture assignment was not saved.\n\n#{result[:error]}")
        return
      end

      apply_current_texture(result[:cue]) if result[:current]
      sync_scene_markers
      refresh(@dialog)
    end

    def apply_current_texture(cue)
      model = Sketchup.active_model
      preferred = LibraryAssociation.folder_name(model)
      if preferred && !model.path.to_s.empty?
        discovery = TextureLibraryStatus.discover(File.dirname(model.path), preferred)
        if discovery[:root] && TextureLibraryStatus.layout(discovery[:root]) == :scene_first
          TextureApplier.apply(model, discovery[:root], cue)
          return
        end
      end

      if defined?(SceneTextureSwitcher::Core) && SceneTextureSwitcher::Core.respond_to?(:apply_all_textures)
        SceneTextureSwitcher::Core.apply_all_textures(cue)
      else
        puts '[SceneTextureOverview] Assignment saved; production switcher is unavailable for immediate application.'
      end
    end

    def reload_current_scene_textures
      scene = Sketchup.active_model.pages.selected_page
      if scene
        cue = scene.get_attribute('SceneTextureSwitcher', 'texture_index', '01')
        apply_current_texture(TextureLibraryStatus.normalize_cue(cue))
      end
      sync_scene_markers
      refresh(@dialog)
    end

    def activate_scene(scene_key)
      model = Sketchup.active_model
      page = SceneAssignment.find_page(model.pages, scene_key)
      return unless page

      model.pages.selected_page = page unless page.equal?(model.pages.selected_page)
      schedule_refresh
    end

    def migrate_scene_first_copy
      model = Sketchup.active_model
      if model.path.to_s.empty?
        UI.messagebox('Save the SketchUp model before creating a scene-first texture copy.')
        return
      end

      project_dir = File.dirname(model.path)
      source = legacy_source(project_dir)
      unless source
        UI.messagebox('Exactly one legacy Surface## texture library is required for migration.')
        return
      end

      model_label = SceneMarkerName.sanitize(File.basename(model.path, File.extname(model.path)), 80)
      destination_name = "Textures — #{model_label}"
      destination = File.join(project_dir, destination_name)
      if File.exist?(destination)
        UI.messagebox("The migration destination already exists:\n\n#{destination}\n\nNothing was changed.")
        return
      end

      answer = UI.messagebox(
        "Create a verified scene-first copy?\n\n" \
        "Source: #{source}\nDestination: #{destination}\n\n" \
        'The existing texture library will not be changed.',
        MB_YESNO
      )
      return unless answer == IDYES

      scan = LegacyLibraryScanner.new(source).scan
      plan = MigrationPlanner.new(scan).plan
      scenes = scene_records(model)
      result = VerifiedSceneFirstMigration.new(plan, SceneMarkerName).execute(destination, scenes)

      adopt = UI.messagebox(
        "Verified copy complete.\n\n" \
        "Textures copied: #{result[:copied].length}\nScene labels: #{result[:markers].length}\n" \
        "Report: #{result[:report_path]}\n\n" \
        'Use this scene-first copy for the current model?',
        MB_YESNO
      )
      adopt_library(model, destination_name) if adopt == IDYES
      refresh(@dialog)
    rescue StandardError => error
      UI.messagebox("Scene-first copy was not completed.\n\n#{error.message}\n\nThe legacy library was not changed.")
    end

    def adopt_library(model, folder_name)
      model.start_operation('Adopt Scene Texture Library', true)
      LibraryAssociation.set(model, folder_name)
      model.commit_operation
      SceneFirstBridge.install
      scene = model.pages.selected_page
      if scene
        cue = scene.get_attribute('SceneTextureSwitcher', 'texture_index', '01')
        apply_current_texture(TextureLibraryStatus.normalize_cue(cue))
      end
    rescue StandardError
      model.abort_operation
      raise
    end

    def adopt_existing_scene_first_copy
      model = Sketchup.active_model
      if model.path.to_s.empty?
        UI.messagebox('Save the SketchUp model before adopting a texture library.')
        return
      end

      project_dir = File.dirname(model.path)
      candidates = Dir.children(project_dir).sort.map do |entry|
        path = File.join(project_dir, entry)
        next unless File.directory?(path) && entry.match?(TextureLibraryStatus::LIBRARY_NAME)
        next unless TextureLibraryStatus.layout(path) == :scene_first
        next unless File.file?(File.join(path, VerifiedSceneFirstMigration::REPORT_NAME))

        path
      end.compact
      unless candidates.length == 1
        UI.messagebox('Exactly one verified scene-first copy must be beside the model for automatic adoption.')
        return
      end

      library = candidates.first
      answer = UI.messagebox(
        "Use this verified scene-first copy for the current model?\n\n#{library}\n\n" \
        'The legacy texture library will remain unchanged.',
        MB_YESNO
      )
      return unless answer == IDYES

      adopt_library(model, File.basename(library))
      refresh(@dialog)
    rescue StandardError => error
      UI.messagebox("The scene-first copy was not adopted.\n\n#{error.message}")
    end

    def legacy_source(project_dir)
      candidates = Dir.children(project_dir).sort.map do |entry|
        path = File.join(project_dir, entry)
        path if File.directory?(path) && entry.match?(TextureLibraryStatus::LIBRARY_NAME) &&
          TextureLibraryStatus.layout(path) == :legacy
      end.compact
      candidates.length == 1 ? candidates.first : nil
    end

    def scene_records(model)
      model.pages.each_with_index.map do |page, index|
        {
          cue: page.get_attribute('SceneTextureSwitcher', 'texture_index', '01'),
          name: page.name.to_s,
          scene_key: SceneAssignment.key_for(page, index)
        }
      end
    end

    def sync_scene_markers
      model = Sketchup.active_model
      return if model.path.to_s.empty?

      preferred = LibraryAssociation.folder_name(model)
      return unless preferred

      discovery = TextureLibraryStatus.discover(File.dirname(model.path), preferred)
      root = discovery[:root]
      return unless root && TextureLibraryStatus.layout(root) == :scene_first

      SceneMarkerSync.sync(root, scene_records(model))
    rescue StandardError => error
      puts "[SceneTextureOverview] Scene label sync failed: #{error.class}: #{error.message}"
    end

    def schedule_refresh
      return if @refresh_scheduled

      @refresh_scheduled = true
      UI.start_timer(0.1, false) do
        @refresh_scheduled = false
        sync_scene_markers
        refresh(@dialog) if @dialog
      end
    end

    def attach_pages_observer
      pages = Sketchup.active_model.pages
      return if @observed_pages.equal?(pages)

      detach_pages_observer
      @pages_observer ||= OverviewPagesObserver.new(self)
      pages.add_observer(@pages_observer)
      @observed_pages = pages
    end

    def detach_pages_observer
      @observed_pages.remove_observer(@pages_observer) if @observed_pages && @pages_observer
      @observed_pages = nil
    rescue StandardError => error
      puts "[SceneTextureOverviewPreview] Could not detach observer: #{error.message}"
      @observed_pages = nil
    end
  end

  unless file_loaded?(__FILE__)
    UI.menu('Extensions').add_item('Scene Texture Overview — Development') {
      OverviewPreview.activate
    }
    UI.menu('Extensions').add_item('Create Verified Scene-First Texture Copy…') {
      OverviewPreview.migrate_scene_first_copy
    }
    UI.menu('Extensions').add_item('Adopt Existing Scene-First Texture Copy…') {
      OverviewPreview.adopt_existing_scene_first_copy
    }
    file_loaded(__FILE__)
  end
end
