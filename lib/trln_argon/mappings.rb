require 'json'
require 'singleton'

module TrlnArgon
  module Loggable
    def logger
      @logger ||= Rails.logger
    end
  end

  # Provides locally stored code mappings supplied by the host application.
  #
  # Expected directory structure:
  #
  # config/mappings/argon_mappings/
  # └── unc/
  #     ├── location_item_holdings.json
  #     ├── location_facet.json
  #     └── url_template.json
  #
  class MappingsGitFetcher
    include Loggable

    REPO_NAME = 'argon_mappings'.freeze

    attr_reader :repo_dir

    def initialize(options = {})
      repo_base = options.fetch(:repo_base, Rails.root.join('config', 'mappings').to_s)
      @repo_dir = options.fetch(:repo_dir, File.join(repo_base, REPO_NAME))
      @repo_dir = File.expand_path(@repo_dir)

      warn_if_missing
      logger.info("Using local code mappings at #{@repo_dir}")
    end

    # Kept for compatibility with the existing LookupManager.
    # No Git refresh is performed.
    def refresh
      warn_if_missing
      logger.debug("Using local code mappings at #{@repo_dir}")
      true
    end

    private

    def warn_if_missing
      return if File.directory?(@repo_dir)

      logger.warn("Local code mappings directory does not exist: #{@repo_dir}; using empty mappings")
    end
  end

  class Lookups
    include Loggable

    attr_reader :directory

    KEYS = {
      loc_b: 'loc_b',
      loc_n: 'loc_n'
    }.freeze

    FILENAMES = {
      location_holdings: 'location_item_holdings.json',
      location_facet: 'location_facet.json',
      url_template: 'url_template.json'
    }.freeze

    def initialize(base = '.')
      @directory = base
      reload!
    end

    # Looks up a display value given a path of the form:
    #
    #   [inst_code].[lookup_type].[code]
    #
    # For example:
    #
    #   unc.location_facet.uncgrar
    #
    def lookup(path)
      parts = path.split('.')
      context = @mappings

      parts.each do |key|
        context = context[key]
        break if context.nil? || context.empty?
      end

      context.nil? ? path : context
    end

    def mappings
      @mappings ||= load
    end

    def reload!
      @mappings = load
    end

    def load
      mappings = {}
      return mappings unless File.directory?(@directory)

      Dir.foreach(@directory) do |dir_entry|
        path = File.expand_path(File.join(@directory, dir_entry))

        next unless File.directory?(path)
        next unless dir_entry.match?(/\A[a-z]/)

        inst_code = File.basename(path)
        inst_mappings = mappings[inst_code] = {}

        holdings_file = File.join(
          path,
          FILENAMES[:location_holdings]
        )
        parse_holdings!(holdings_file, inst_mappings)

        facet_file = File.join(
          path,
          FILENAMES[:location_facet]
        )
        facets = read_json(facet_file)

        url_template_file = File.join(
          path,
          FILENAMES[:url_template]
        )
        url_templates = read_json(url_template_file)

        inst_mappings['loc_b'].each do |key, value|
          facets[key] ||= value
        end

        inst_mappings['facet'] = facets
        inst_mappings['url_template'] = url_templates
      end

      mappings
    end

    private

    def parse_holdings!(filename, inst_mappings)
      lookups = read_json(filename)

      loc_b_mappings = (inst_mappings['loc_b'] ||= {})
      locations_broad = lookups.fetch(KEYS[:loc_b], {})
      loc_b_mappings.update(locations_broad)

      loc_n_mappings = (inst_mappings['loc_n'] ||= {})
      locations_narrow = lookups.fetch(KEYS[:loc_n], {})
      loc_n_mappings.update(locations_narrow)
    end

    def read_json(filename)
      return {} unless File.exist?(filename)

      File.open(filename) do |file|
        JSON.parse(file.read)
      end
    end
  end

  # Manages mappings for location broad/narrow names, statuses, and related
  # lookup values.
  class LookupManager
    include Loggable
    include Singleton

    # The cache stores a canary value rather than the mappings themselves.
    CACHE_KEY = 'TrlrArgon::LookupManager::Lookups::Canary'.freeze

    attr_reader :dev_reload_file

    class << self
      attr_writer :fetcher

      def fetcher
        @fetcher ||= MappingsGitFetcher.new
      end
    end

    def initialize
      if Rails.env.development?
        @dev_reload_file = File.join(Rails.root, 'tmp', 'reload-code-mappings')
        logger.info("Development mode: Argon code mappings are loaded at startup and when #{@dev_reload_file} exists.")
      end

      reload
    end

    # Verifies the local mappings directory and clears the cache marker.
    def reload
      self.class.fetcher.refresh
      Rails.cache.delete(CACHE_KEY)
    end

    def map(path)
      lookups.lookup(path)
    end

    def check_cache
      if Rails.env.development? &&
         dev_reload_file &&
         File.exist?(dev_reload_file)

        logger.info(
          "Found #{@dev_reload_file}, reloading Argon code mappings"
        )

        @lookups = nil
        File.unlink(dev_reload_file)

        logger.info(
          "Removed #{@dev_reload_file}. Use " \
            'bundle exec rake trln_argon:reload_code_mappings ' \
            'to reload mappings again.'
        )
      end

      Rails.cache.fetch(CACHE_KEY, expires_in: 24.days) do
        logger.info('Location code mappings not found in cache, reloading')

        @lookups = nil
        Time.now.to_s
      end
    end

    def lookups
      check_cache
      @lookups ||= Lookups.new(self.class.fetcher.repo_dir)
    end
  end
end
