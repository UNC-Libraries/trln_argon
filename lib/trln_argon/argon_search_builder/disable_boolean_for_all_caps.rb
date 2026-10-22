module TrlnArgon
  module ArgonSearchBuilder
    module DisableBooleanForAllCaps
      # Turn Boolean off by downcasing the query if there
      # are no lowercase letters present, likely indicating
      # a copy/paste all caps query where Boolean query
      # behavior is not expected
      def disable_boolean_for_all_caps(solr_parameters)
        return unless search_state.params &&
                      search_state.params[:q].present? &&
                      search_state.params[:q].respond_to?(:match) &&
                      search_state.params[:q].match(/\s(AND|OR|NOT)\s/) &&
                      !search_state.params[:q].match(/[a-z]+/)
        solr_parameters[:q] = solr_parameters[:q].downcase
      end
    end
  end
end
