module TrlnArgon
  module ArgonSearchBuilder
    module ShareBookmarks
      def add_document_ids_query(solr_parameters)
        return unless search_state.params[:doc_ids].present?
        solr_parameters['q'] = "{!lucene}id:(#{cleaned_bookmark_params})"
        solr_parameters['defType'] = 'lucene'
      end

      def cleaned_bookmark_params
        search_state.params[:doc_ids].delete('^a-zA-Z0-9|').gsub('|', ' OR ') # UNCb9249630 OR UNCb9001022
      end
    end
  end
end
