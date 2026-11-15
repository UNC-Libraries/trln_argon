describe TrlnArgon::UrlSafety do
  describe '.allowed_scheme?' do
    it 'rejects dangerous schemes case-insensitively' do
      urls = %w[javascript:alert(1) VBSCRIPT:msgbox(1) data:text/html,Hi
                file:///tmp/file blob:https://example.com/id]

      urls.each do |url|
        expect(described_class.allowed_scheme?(url)).to be false
      end
    end

    it 'rejects leading whitespace and control-character obfuscation' do
      urls = ['  javascript:alert(1)', "java\tscript:alert(1)",
              "java\nscript:alert(1)", "https://example.com\rmalicious"]

      urls.each do |url|
        expect(described_class.allowed_scheme?(url)).to be false
      end
    end

    it 'preserves other schemes and relative URLs' do
      urls = %w[https://example.com ftp://example.com gopher://example.com
                mailto:user@example.com /relative/path]

      urls.each do |url|
        expect(described_class.allowed_scheme?(url)).to be true
      end
    end
  end
end
