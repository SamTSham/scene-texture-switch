# frozen_string_literal: true

Sketchup.require File.join(__dir__.dup.force_encoding(Encoding::UTF_8), 'namespace') unless defined?(SamMadwar::SceneTextureSwitch)

module SamMadwar::SceneTextureSwitch
  module TextureApplier
    extend self

    SURFACE_COUNT = 99

    def apply(model, library_root, cue)
      operation_started = false
      normalized_cue = TextureLibraryStatus.normalize_cue(cue)
      layout = TextureLibraryStatus.layout(library_root)
      result = { cue: normalized_cue, layout: layout, applied: [], missing: [], errors: [] }

      # Scene changes and the safety poll can invoke this without a direct user
      # action. Keep every material update in one transparent undo operation.
      model.start_operation('Apply Scene Textures', true, false, true)
      operation_started = true

      (1..SURFACE_COUNT).each do |number|
        material_name = format('Surface%02d', number)
        material = model.materials[material_name]
        next unless material

        texture_path = preferred_texture(library_root, layout, material_name, normalized_cue)
        unless texture_path
          result[:missing] << material_name
          next
        end

        begin
          old_width = material.texture ? material.texture.width : 100
          old_height = material.texture ? material.texture.height : 100
          material.texture = texture_path
          material.texture.size = [old_width, old_height]
          result[:applied] << { material: material_name, path: texture_path }
        rescue StandardError => error
          result[:errors] << { material: material_name, path: texture_path, error: error.message }
        end
      end
      model.commit_operation
      operation_started = false
      result
    rescue StandardError
      model.abort_operation if operation_started
      raise
    end

    def preferred_texture(root, layout, material_name, cue)
      TextureLibraryStatus::SUPPORTED_EXTENSIONS.each do |extension|
        path = case layout
               when :scene_first
                 File.join(root, cue, "#{material_name}#{extension}")
               when :legacy
                 File.join(root, material_name, "#{cue}#{extension}")
               else
                 next
               end
        return path if File.file?(path)
      end
      nil
    end
  end
end
