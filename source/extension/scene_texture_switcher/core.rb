require 'json'
require File.join(__dir__, 'texture_library_status')
require File.join(__dir__, 'scene_snapshot')
require File.join(__dir__, 'overview_pages_observer')
require File.join(__dir__, 'scene_assignment')
require File.join(__dir__, 'library_association')

module SceneTextureSwitcher
  module Core
    extend self

    SURFACE_COUNT = 99
    BASE_TEXTURE_FOLDER = 'textures'

    def activate
      dlg = UI::HtmlDialog.new({
        :dialog_title => "Select Texture Cue",
        :preferences_key => "SceneTextureSwitcher",
        :scrollable => false,
        :resizable => false,
        :width => 300,
        :height => 200,
        :style => UI::HtmlDialog::STYLE_DIALOG
      })

      html_path = File.join(__dir__, "html", "dropdown.html")
      dlg.set_file(html_path)

      dlg.add_action_callback("setCue") do |_, cue|
        model = Sketchup.active_model
        scene = model.pages.selected_page
        puts "Storing cue #{cue} for scene: #{scene.name}"
        scene.set_attribute('SceneTextureSwitcher', 'texture_index', cue)
        apply_all_textures(cue)
        dlg.close
      end

      dlg.show
    end

    # Opens a read-only overview beside the established selector. The overview
    # receives snapshots only and cannot apply textures or alter scene data.
    def activate_overview
      if @overview_dialog && @overview_dialog.visible?
        @overview_dialog.bring_to_front
        refresh_overview(@overview_dialog)
        return
      end

      @overview_dialog = UI::HtmlDialog.new({
        :dialog_title => 'Scene Textures — Development',
        :preferences_key => 'SceneTextureSwitcherOverview',
        :scrollable => false,
        :resizable => true,
        :width => 360,
        :height => 420,
        :min_width => 300,
        :min_height => 180,
        :style => UI::HtmlDialog::STYLE_DIALOG
      })
      @overview_dialog.set_file(File.join(__dir__, 'html', 'overview.html'))
      @overview_dialog.add_action_callback('requestSnapshot') do |_action_context|
        refresh_overview(@overview_dialog)
      end
      @overview_dialog.add_action_callback('reloadCurrent') do |_action_context|
        reload_current_scene_textures
      end
      @overview_dialog.add_action_callback('setCue') do |_action_context, scene_key, cue|
        assign_overview_cue(scene_key, cue)
      end
      @overview_dialog.add_action_callback('activateScene') do |_action_context, scene_key|
        activate_overview_scene(scene_key)
      end
      @overview_dialog.set_on_closed do
        detach_overview_pages_observer
        @overview_dialog = nil
      end
      @overview_dialog.show
      attach_overview_pages_observer
    end

    def refresh_overview(dialog = @overview_dialog)
      return unless dialog

      model = Sketchup.active_model
      project_dir = model.path.to_s.empty? ? nil : File.dirname(model.path)
      preferred = LibraryAssociation.folder_name(model)
      discovery = TextureLibraryStatus.discover(project_dir, preferred)
      snapshot = SceneSnapshot.build(model, discovery)
      dialog.execute_script("SceneTextureOverview.render(#{JSON.generate(snapshot)})")
    rescue StandardError => error
      puts "[SceneTextureSwitcher] Overview refresh failed: #{error.class}: #{error.message}"
    end

    def assign_overview_cue(scene_key, cue)
      result = SceneAssignment.assign(Sketchup.active_model, scene_key, cue)
      unless result[:success]
        UI.messagebox("Texture assignment was not saved.\n\n#{result[:error]}")
        return
      end

      apply_all_textures(result[:cue]) if result[:current]
      refresh_overview(@overview_dialog)
    end

    def reload_current_scene_textures
      scene = Sketchup.active_model.pages.selected_page
      if scene
        cue = scene.get_attribute('SceneTextureSwitcher', 'texture_index', '01')
        apply_all_textures(TextureLibraryStatus.normalize_cue(cue))
      end
      refresh_overview(@overview_dialog)
    end

    def activate_overview_scene(scene_key)
      model = Sketchup.active_model
      page = SceneAssignment.find_page(model.pages, scene_key)
      return unless page

      model.pages.selected_page = page unless page.equal?(model.pages.selected_page)
      schedule_refresh
    end

    def schedule_refresh
      return if @overview_refresh_scheduled

      @overview_refresh_scheduled = true
      UI.start_timer(0.1, false) do
        @overview_refresh_scheduled = false
        refresh_overview(@overview_dialog) if @overview_dialog
      end
    end

    def attach_overview_pages_observer
      pages = Sketchup.active_model.pages
      return if @overview_observed_pages.equal?(pages)

      detach_overview_pages_observer
      @overview_pages_observer ||= OverviewPagesObserver.new(self)
      pages.add_observer(@overview_pages_observer)
      @overview_observed_pages = pages
    end

    def detach_overview_pages_observer
      if @overview_observed_pages && @overview_pages_observer
        @overview_observed_pages.remove_observer(@overview_pages_observer)
      end
      @overview_observed_pages = nil
    rescue StandardError => error
      puts "[SceneTextureSwitcher] Could not detach overview observer: #{error.message}"
      @overview_observed_pages = nil
    end

    def apply_all_textures(cue)
      model = Sketchup.active_model
      skp_path = model.path
      return unless skp_path && !skp_path.empty?

      project_dir = File.dirname(skp_path)

      (1..SURFACE_COUNT).each do |i|
        mat_name = "Surface%02d" % i
        mat = model.materials[mat_name]
        next unless mat

        tex_path = nil
        ['.png', '.jpg', '.jpeg'].each do |ext|
          try_path = File.join(project_dir, BASE_TEXTURE_FOLDER, mat_name, "#{cue}#{ext}")
          if File.exist?(try_path)
            tex_path = try_path
            break
          end
        end

        if tex_path
          puts "Applying #{tex_path} to #{mat_name}"
          old_width = mat.texture ? mat.texture.width : 100
          old_height = mat.texture ? mat.texture.height : 100
          mat.texture = tex_path
          mat.texture.size = [old_width, old_height]
        else
          puts "Texture not found for #{mat_name} cue #{cue}"
        end
      end
    end

    def on_scene_changed
      model = Sketchup.active_model
      scene = model.pages.selected_page
      cue = scene.get_attribute('SceneTextureSwitcher', 'texture_index', '01')
      puts "Scene changed to: #{scene.name} - applying cue #{cue}"
      apply_all_textures(cue)
    end

    def start_scene_polling
      @last_scene_name = nil
      UI.start_timer(1.0, true) do
        current = Sketchup.active_model.pages.selected_page
        current_name = current ? current.name : nil
        if current_name && current_name != @last_scene_name
          puts "Detected scene switch to: #{current_name}"
          @last_scene_name = current_name
          on_scene_changed
        end
      end
    end
  end

  unless file_loaded?(__FILE__)
    UI.menu('Extensions').add_item('Scene Texture Switcher') {
      Core.activate
    }
    UI.menu('Extensions').add_item('Scene Texture Overview — Preview') {
      Core.activate_overview
    }
    Core.start_scene_polling
    file_loaded(__FILE__)
  end
end
