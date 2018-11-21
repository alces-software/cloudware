# frozen_string_literal: true

RSpec.describe Cloudware::Models::Deployment do
  subject { build(:deployment) }

  context 'with a parent deployment' do
    let(:parent_results) { { parent_key1: 'value1', parent_key2: 'value2' } }
    let(:parent) do
      build(:deployment).tap do |model|
        allow(model).to receive(:results).and_return(parent_results)
      end
    end
    let(:raw_template) {
      <<-TEMPLATE.strip_heredoc
        key1: '%parent_key1%'
        key2: '%parent_key2%'
      TEMPLATE
    }

    subject do
      build(:deployment, parent: parent).tap do |model|
        allow(model).to receive(:raw_template).and_return(raw_template)
      end
    end

    it 'renders the child template' do
      template = Cloudware::Data.load_string(subject.template)
      expect(template[:key1]).to eq(parent_results[:parent_key1])
      expect(template[:key2]).to eq(parent_results[:parent_key2])
    end
  end
end