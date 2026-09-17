def apply_local_configuration(config, config_key)
  return unless ENV.key?(config_key.upcase)

  config.send("#{config_key}=".to_sym, ENV[config_key.upcase])
end

TrlnArgon::Engine.configure do |config|
  apply_local_configuration(config, 'local_institution_code')
  apply_local_configuration(config, 'application_name')
  apply_local_configuration(config, 'refworks_url')
  apply_local_configuration(config, 'root_url')
  apply_local_configuration(config, 'article_search_url')
  apply_local_configuration(config, 'citation_formats')
  apply_local_configuration(config, 'contact_url')
  apply_local_configuration(config, 'feedback_url')
  apply_local_configuration(config, 'sort_order_in_holding_list')
  apply_local_configuration(config, 'number_of_location_facets')
  apply_local_configuration(config, 'number_of_items_index_view')
  apply_local_configuration(config, 'number_of_items_show_view')
  apply_local_configuration(config, 'argon_code_mappings_dir')
  apply_local_configuration(config, 'paging_limit')
  apply_local_configuration(config, 'facet_paging_limit')
  apply_local_configuration(config, 'unc_latest_received_url')
  apply_local_configuration(config, 'solr_cache_exp_time')
  apply_local_configuration(config, 'allow_open_search')
  apply_local_configuration(config, 'open_search_q_min_length')
  apply_local_configuration(config, 'enable_query_truncation')
  apply_local_configuration(config, 'allow_tracebacks')

  mappings_dir = config.argon_code_mappings_dir.to_s
  mappings_dir = File.join(mappings_dir, 'argon_mappings') unless File.basename(mappings_dir) == 'argon_mappings'

  TrlnArgon::LookupManager.fetcher = TrlnArgon::MappingsGitFetcher.new(
    repo_dir: mappings_dir
  )

  # Initialize the local mappings using a UNC location from config/mappings/argon_mappings/unc.
  TrlnArgon::LookupManager.instance.map('unc.loc_b.d@')
end

# Configure paging defaults
# Set max paging links to that set in Argon config (default 250).
# Set outer window to 0 to prevent direct access to deep pages.
Kaminari.configure do |config|
  config.max_pages = TrlnArgon::Engine.configuration.paging_limit.to_i
  config.outer_window = 0
end
