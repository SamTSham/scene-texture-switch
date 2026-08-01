# frozen_string_literal: true

module SceneTextureSwitcher
  # Development-only runtime bridge. It leaves the production method intact for
  # every unassociated model and routes only an explicitly associated
  # scene-first library through TextureApplier.
  module SceneFirstBridge
    extend self

    LEGACY_METHOD = :apply_all_textures_without_scene_first_bridge

    def install
      return false unless defined?(SceneTextureSwitcher::Core)

      core = SceneTextureSwitcher::Core
      singleton = core.singleton_class
      return true if singleton.method_defined?(LEGACY_METHOD)
      return false unless core.respond_to?(:apply_all_textures)

      singleton.alias_method(LEGACY_METHOD, :apply_all_textures)
      singleton.define_method(:apply_all_textures) do |cue|
        model = Sketchup.active_model
        preferred = LibraryAssociation.folder_name(model)
        if preferred && !model.path.to_s.empty?
          discovery = TextureLibraryStatus.discover(File.dirname(model.path), preferred)
          if discovery[:root] && TextureLibraryStatus.layout(discovery[:root]) == :scene_first
            return TextureApplier.apply(model, discovery[:root], cue)
          end
        end

        public_send(SceneFirstBridge::LEGACY_METHOD, cue)
      end
      true
    end
  end
end
