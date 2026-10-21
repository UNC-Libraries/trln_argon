# frozen_string_literal: true

module TrlnArgon
  module ArgonSearchBuilder
    module AuthorBoost
      def author_boost(solr_parameters)
        return unless includes_author_search?

        solr_parameters[:bq] ||= []
        solr_parameters[:bq] << author_english_boost_query

        solr_parameters[:bf] ||= []
        solr_parameters[:bf] << author_recent_boost_function
      end

      private

      def author_recent_boost_function
        current_year = Date.today.year
        current_year_plus_two = current_year + 2
        current_year_minus_ten = current_year - 10
        'linear(map(' \
        "#{TrlnArgon::Fields::PUBLICATION_YEAR_SORT},#{current_year_plus_two},10000," \
        "#{current_year_minus_ten},abs(#{TrlnArgon::Fields::PUBLICATION_YEAR_SORT})),11,0)^0.5"
      end

      def author_english_boost_query
        "#{TrlnArgon::Fields::LANGUAGE_FACET}:English^500"
      end

      def includes_author_search?
        search_state.params.key?('search_field') &&
          ((search_state.params['search_field'] == 'author') ||
          (search_state.params['search_field'] == 'advanced' &&
          search_state.params.fetch('author', nil).present?))
      end
    end
  end
end
