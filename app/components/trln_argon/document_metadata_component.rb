module TrlnArgon
  class DocumentMetadataComponent < Blacklight::DocumentMetadataComponent
    def initialize(fields: [], tag: 'dl', classes: %w[document-metadata dl-invert row],
      show: false, view_type: nil, field_layout: nil, **component_args)
      fields = fields.map(&:itself) if fields.is_a?(Enumerator)

      super(
        fields: fields,
        tag: tag,
        classes: classes,
        show: show,
        view_type: view_type,
        field_layout: field_layout,
        **component_args
      )
    end

    def render?
      @fields.present?
    end
  end
end
