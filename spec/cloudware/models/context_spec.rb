# frozen_string_literal: true
require 'models/context'

RSpec.describe Cloudware::Models::Context do
  subject do
    described_class.new.tap do |context|
      allow(context).to receive(:deployments).and_return(deployments)
    end
  end

  context 'with a single deployment' do
    let(:results) { { key: 'value' } }
    let(:deployment) { build(:deployment, results: results) }
    let(:deployments) { [deployment] }

    describe '#results' do
      it "returns the deployment's results" do
        expect(subject.results).to eq(deployments.first.results)
      end
    end
  end

  context 'with multiple deployments' do
    let(:initial_results) { { key: 'value', replaced_key: 'wrong' } }
    let(:final_results) { { replaced_key: 'correct' } }
    let(:merged_results) { initial_results.merge(final_results) }

    let(:initial_deployment) { build(:deployment, results: initial_results) }
    let(:final_deployment) { build(:deployment, results: final_results) }
    let(:deployments) { [initial_deployment, final_deployment] }

    it 'replaces the earlier results with the latter' do
      expect(subject.results).to eq(merged_results)
    end
  end
end
