module TrlnArgon
  class MetadataFieldLayoutComponent < Blacklight::MetadataFieldLayoutComponent
    # preserve the parent component’s options
    # @param field [Blacklight::FieldPresenter]
    # @param label_class [String]
    # @param value_class [String]
    def initialize(field:, label_class: '', value_class: '', **options)
      super(
        field: field,
        label_class: label_class,
        value_class: value_class,
        **options
      )
    end
  end
end
