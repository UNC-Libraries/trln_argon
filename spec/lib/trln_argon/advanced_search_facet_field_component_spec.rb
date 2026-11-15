describe TrlnArgon::AdvancedSearchFacetFieldComponent do
  describe '#display_value' do
    let(:display_facet) { Struct.new(:name).new('subject_topical_f') }
    let(:facet_field) { Struct.new(:key, :display_facet).new('subject_topical_f', display_facet) }
    let(:facet_item) { Struct.new(:label, :hits).new('<img src=x onerror=alert(1)>', 12) }

    it 'escapes the facet label and preserves count formatting' do
      component = described_class.new(facet_field: facet_field)

      expect(component.display_value(facet_item)).to(
        eq('&lt;img src=x onerror=alert(1)&gt;&nbsp;&nbsp;(12)')
      )
    end
  end
end
