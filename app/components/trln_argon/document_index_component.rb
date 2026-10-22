module TrlnArgon
  # DocumentComponent for use on Index (results) pages;
  # replaces metadata slot with basic "subheader" content
  class DocumentIndexComponent < Blacklight::DocumentComponent
    def before_render
      with_metadata(
        fields: @presenter&.field_presenters,
        component: TrlnArgon::DocumentHeaderMetadataComponent
      )
      super
    end
  end
end
