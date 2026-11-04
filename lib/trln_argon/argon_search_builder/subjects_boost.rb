# frozen_string_literal: true

module TrlnArgon
  module ArgonSearchBuilder
    module SubjectsBoost
      def subjects_boost(solr_parameters)
        return unless includes_subject_search?

        solr_parameters[:bq] ||= []
        solr_parameters[:bq] << subjects_english_boost_query
        solr_parameters[:bq] << subjects_title_boost_query
        solr_parameters[:bq] << subjects_books_boost_query

        solr_parameters[:bf] ||= []
        solr_parameters[:bf] << subjects_recent_boost_function
      end

      private

      def subjects_recent_boost_function
        current_year = Date.today.year
        current_year_plus_two = current_year + 2
        current_year_minus_ten = current_year - 10
        'linear(map(' \
        "#{TrlnArgon::Fields::PUBLICATION_YEAR_SORT},#{current_year_plus_two},10000," \
        "#{current_year_minus_ten},abs(#{TrlnArgon::Fields::PUBLICATION_YEAR_SORT})),11,0)^5"
      end

      def subjects_books_boost_query
        "#{TrlnArgon::Fields::RESOURCE_TYPE_FACET}:Book^10"
      end

      def subjects_english_boost_query
        "#{TrlnArgon::Fields::LANGUAGE_FACET}:English^1000"
      end

      def subjects_title_boost_query
        if search_state.params.key?(:q) &&
           search_state.params[:q].present?
          standard_search_title_boost
        elsif search_state.params.key?('subject') &&
              search_state.params['subject'].present?
          advanced_search_title_boost
        end
      end

      def standard_search_title_boost
        "#{TrlnArgon::Fields::TITLE_MAIN_INDEXED_NO_STEM}:"\
        "(#{RSolr.solr_escape(search_state.params[:q])})^50"
      end

      def advanced_search_title_boost
        "#{TrlnArgon::Fields::TITLE_MAIN_INDEXED_NO_STEM}:"\
        "(#{RSolr.solr_escape(search_state.params['subject'])})^50"
      end

      def includes_subject_search?
        search_state.params.key?('search_field') &&
          (['subject', 'genre_headings'].include?(search_state.params['search_field']) ||
          (search_state.params['search_field'] == 'advanced' &&
          search_state.params.fetch('subject', nil).present?))
      end
    end
  end
end
