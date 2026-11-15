module TrlnArgon
  module UrlSafety
    BLOCKED_SCHEMES = %w[blob data file javascript vbscript].freeze
    ASCII_CONTROL_CHARACTER = /[\u0000-\u001F\u007F]/
    URI_SCHEME = /\A([a-z][a-z0-9+.-]*):/i

    def self.allowed_scheme?(value)
      url = value.to_s
      return false if url.match?(ASCII_CONTROL_CHARACTER)

      scheme = url.lstrip[URI_SCHEME, 1]
      scheme.nil? || !BLOCKED_SCHEMES.include?(scheme.downcase)
    end
  end
end
