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
    Core.start_scene_polling
    file_loaded(__FILE__)
  end
end
