# frozen_string_literal: true

module TrlnArgon
  class ConstraintComponent < Blacklight::ConstraintComponent
    def initialize(facet_item_presenter:, classes: %w[filter], layout: TrlnArgon::ConstraintLayoutComponent)
      super(facet_item_presenter: facet_item_presenter, classes: classes, layout: layout)
    end
  end
end
