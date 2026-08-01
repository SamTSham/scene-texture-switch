module SceneTextureSwitcher
  module Core
    extend self

    SURFACE_COUNT = 99

# Locate texture folders relative to the active model file
model_path = Sketchup.active_model.path
project_dir = File.dirname(model_path)
texture_dir = File.join(project_dir, 'textures')
surfaces = Dir.glob(File.join(texture_dir, 'Surface*')).select { |f| File.directory?(f) }
surface_count = surfaces.length
puts '\n[SceneTextureSwitcher] USING MODEL PATH:'
puts 'Model path: ' + model_path
puts 'Project dir: ' + project_dir
puts 'Texture dir: ' + texture_dir
puts 'Surface folders:'
surfaces.each { |f| puts ' - ' + f }
puts 'Surface count: ' + surface_count.to_s
puts '---'

puts '\n[SceneTextureSwitcher] SCANNING TEXTURES:'
puts 'Looking in: ' + File.dirname(__FILE__)
puts 'Surface folders:'
Dir.glob(File.join(File.dirname(__FILE__), '../../textures/Surface*')).each { |f| puts ' - ' + f }
puts '---'

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

      # Prepare dropdown data once requested
      model = Sketchup.active_model
      path = File.join(model.path.gsub(/\.skp$/, ''), BASE_TEXTURE_FOLDER)
      surfaces = Dir.glob(File.join(path, 'Surface*')).select { |f| File.directory?(f) }
      surface_count = surfaces.size

    # Precompute color logic for each texture number
    texture_icon_map = {}
    (1..SURFACE_COUNT).each do |i|
      cue = format('%02d', i)
      count = surfaces.count do |folder|
        %w(.jpg .jpeg .png).any? do |ext|
          path = File.join(folder, "#{cue}#{ext}")
          puts "Checking: #{path}"
          File.exist?(path)
        end
      end
      icon = case count
        when surface_count then '⬛'
        when 1...surface_count then '🟥'
        else '⬜'
      end
      texture_icon_map[cue] = icon
    end
      dropdown_items = (1..SURFACE_COUNT).map do |i|
      icon = texture_icon_map[format('%02d', i)] || '⬜'
        count = surfaces.count do |folder|
          %w(.jpg .jpeg .png).any? { |ext| File.exist?(File.join(folder, format('%02d', i) + ext)) }
        end

        icon = case count
          when surface_count then '⬛'
          when 1...surface_count then '🟥'
          else '⬜'
        end

        "#{icon} #{format('%02d', i)}"
      end

      require 'json'
      dlg.add_action_callback("requestDropdown") do |_action_context|
        model = Sketchup.active_model
        scene = model.pages.selected_page
        current_index = scene.get_attribute('SceneTextureSwitcher', 'texture_index', '01')
        current_index = format('%02d', current_index.to_i)

        path = File.join(model.path.gsub(/\.skp$/, ''), BASE_TEXTURE_FOLDER)
        surfaces = Dir.glob(File.join(path, 'Surface*')).select { |f| File.directory?(f) }
        surface_count = surfaces.size

        dropdown_items = (1..SURFACE_COUNT).map do |i|
      icon = texture_icon_map[format('%02d', i)] || '⬜'
          count = surfaces.count do |folder|
            %w(.jpg .jpeg .png).any? { |ext| File.exist?(File.join(folder, format('%02d', i) + ext)) }
          end

          icon = case count
            when surface_count then '⬛'
            when 1...surface_count then '🟥'
            else '⬜'
          end

          "#{icon} #{format('%02d', i)}"
        end

        require 'json'
        dlg.execute_script("populateDropdown(" + JSON.generate(dropdown_items) + ")")
        dlg.execute_script("document.getElementById('cueSelector').value = '" + dropdown_items.find { |e| e.include?(current_index) } + "'")
      end
        

      # Populate the dropdown with emoji + number strings
      model = Sketchup.active_model
      path = File.join(model.path.gsub(/\.skp$/, ''), BASE_TEXTURE_FOLDER)
      surfaces = Dir.glob(File.join(path, 'Surface*')).select { |f| File.directory?(f) }
      surface_count = surfaces.size

      dropdown_items = (1..SURFACE_COUNT).map do |i|
      icon = texture_icon_map[format('%02d', i)] || '⬜'
        count = surfaces.count do |folder|
          %w(.jpg .jpeg .png).any? { |ext| File.exist?(File.join(folder, format('%02d', i) + ext)) }
        end

        icon = case count
          when surface_count then '⬛'
          when 1...surface_count then '🟥'
          else '⬜'
        end

        "#{icon} #{format('%02d', i)}"
      end

      dlg.add_action_callback("requestDropdown") { |_,_| dlg.execute_script("populateDropdown(" + dropdown_items.to_s + ")") }
      UI.start_timer(0.2, false) { dlg.run_action("requestDropdown") }
    

      dlg.add_action_callback("setCue") do |_, cue|
        model = Sketchup.active_model
        scene = model.pages.selected_page
        puts "Storing cue #{cue} for scene: #{scene.name}"
        scene.set_attribute('SceneTextureSwitcher', 'texture_index', cue)
        apply_all_textures(cue)
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
      UI.start_timer(0.25, true) do
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

    def list_texture_cues
      model = Sketchup.active_model
      skp_path = model.path
      return [] unless skp_path && !skp_path.empty?

      project_dir = File.dirname(skp_path)
      base_dir = File.join(project_dir, BASE_TEXTURE_FOLDER)
      return [] unless Dir.exist?(base_dir)

      cues = Dir.entries(base_dir)
        .select { |entry| File.directory?(File.join(base_dir, entry)) && entry.match?(/^Surface\d+$/) }
        .flat_map do |surface_folder|
          surface_path = File.join(base_dir, surface_folder)
          Dir.entries(surface_path)
            .select { |f| f =~ /^(\d+)\.(png|jpg|jpeg)$/i }
            .map { |f| f[/^(\d+)/, 1] }
        end
        .uniq
        .compact
        .sort

      cues.map do |cue|
        total = 0
        existing = 0
        (1..SURFACE_COUNT).each do |i|
          mat_name = "Surface%02d" % i
          ['.png', '.jpg', '.jpeg'].each do |ext|
            tex_path = File.join(base_dir, mat_name, "#{cue}#{ext}")
            if File.exist?(tex_path)
              existing += 1
              break
            end
          end
          total += 1
        end
        status = if existing == 0
                   'missing'
                 elsif existing < total
                   'incomplete'
                 else
                   'ready'
                 end
        { cue: cue, status: status }
      end
    end

  end
end
