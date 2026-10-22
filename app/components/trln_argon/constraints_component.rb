module TrlnArgon
  class ConstraintsComponent < Blacklight::ConstraintsComponent
    # rubocop:disable Metrics/ParameterLists
    def initialize(
      search_state:,
      tag: :div,
      render_headers: true,
      heading_classes: 'constraints-label h6 mb-0',
      id: 'appliedParams',
      classes: 'clearfix constraints-container mb-2 align-items-center',
      query_constraint_component: TrlnArgon::ConstraintLayoutComponent,
      query_constraint_component_options: {},
      facet_constraint_component: TrlnArgon::ConstraintComponent,
      facet_constraint_component_options: {},
      start_over_component: TrlnArgon::StartOverButtonComponent
    )
      super
    end
    # rubocop:enable Metrics/ParameterLists
  end
end
