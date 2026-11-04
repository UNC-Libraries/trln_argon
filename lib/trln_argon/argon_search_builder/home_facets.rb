module TrlnArgon
  module ArgonSearchBuilder
    module HomeFacets
      def only_home_facets(solr_parameters)
        return if search_parameters?
        solr_parameters['facet.field'] =
          field_keys_with_ex(blacklight_config.home_facet_fields)
        solr_parameters['facet.pivot'] = []
      end

      def search_parameters?
        sf = search_state.params[:search_field]
        search_state.params[:q].present? ||
          search_state.params[:f].present? ||
          (sf.present? && sf != 'advanced')
      end

      private

      def field_keys_with_ex(home_facet_config)
        home_facet_config.map do |k, v|
          if v.ex
            "{!ex=#{v.ex}}#{k}"
          else
            k
          end
        end
      end
    end
  end
end
