module TrlnArgon
  module ArgonSearchBuilder
    module MinMatch
      def min_match_for_boolean(solr_parameters)
        return unless search_state.params &&
                      search_state.params[:q].present? &&
                      search_state.params[:q].respond_to?(:match) &&
                      search_state.params[:q].match(/\s(AND|OR|NOT)\s/) &&
                      search_state.params[:q].match(/[a-z]+/)
        solr_parameters[:mm] = '1'
      end

      # Adapted from https://github.com/pulibrary/orangelight/blob/master/app/helpers/blacklight_helper.rb
      # Adapted from http://discovery-grindstone.blogspot.com/2014/01/cjk-with-solr-for-libraries-part-12.html
      def min_match_for_cjk(solr_parameters)
        return unless search_state.params &&
                      search_state.params[:q].present? &&
                      cjk_unigrams_size(search_state.params[:q]) > 2
        solr_parameters[:mm] =
          calc_min_match_for_cjk(num_non_cjk_tokens(search_state.params[:q]))
      end

      # Adjust min match setting for title searches with inital articles
      # Users should be able to search for titles with or without
      # initial articles even if the title does not include them.
      def min_match_for_titles(solr_parameters)
        return unless includes_title_search?

        query = search_state.params.fetch(:q, nil) ||
                search_state.params.fetch('title', nil)

        return unless query.present? && query.strip.match(/^(the|a|an)\s/i)

        token_count = query.gsub(/[[:punct:]]/, ' ').split.count

        return unless token_count > 3

        solr_parameters[:mm] = "#{token_count - 1}<95%"
      end

      private

      def calc_min_match_for_cjk(num_non_cjk_tokens)
        return cjk_min_match_value if num_non_cjk_tokens.zero?
        (cjk_min_match_value[0].to_i + num_non_cjk_tokens).to_s +
          cjk_min_match_value[1, cjk_min_match_value.size]
      end

      def includes_title_search?
        search_state.params.key?('search_field') &&
          ((search_state.params['search_field'] == 'title') ||
          (search_state.params['search_field'] == 'advanced' &&
          search_state.params.fetch('title', nil).present?))
      end

      def num_non_cjk_tokens(q_param)
        if q_param && q_param.respond_to?(:scan)
          q_param.gsub(/\p{Han}|\p{Katakana}|\p{Hiragana}|\p{Hangul}/, '')
                 .scan(/[[:alnum:]]+/).size
        else
          0
        end
      end

      def cjk_unigrams_size(q_param)
        if q_param && q_param.respond_to?(:scan)
          q_param.scan(/\p{Han}|\p{Katakana}|\p{Hiragana}|\p{Hangul}/).size
        else
          0
        end
      end

      def cjk_min_match_value
        '3<86%'
      end
    end
  end
end
