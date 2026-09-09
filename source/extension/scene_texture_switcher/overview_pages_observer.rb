# frozen_string_literal: true

Sketchup.require File.join(__dir__.dup.force_encoding(Encoding::UTF_8), 'namespace') unless defined?(SamMadwar::SceneTextureSwitch)

module SamMadwar::SceneTextureSwitch
  # Reports scene-list edits while the overview is open. The receiving owner
  # decides when and how to refresh its snapshot.
  class OverviewPagesObserver < Sketchup::PagesObserver
    def initialize(owner)
      @owner = owner
    end

    def onContentsModified(_pages)
      @owner.schedule_refresh
    end

    def onElementAdded(_pages, _page)
      @owner.schedule_refresh
    end

    def onElementRemoved(_pages, _page)
      @owner.schedule_refresh
    end
  end
end
