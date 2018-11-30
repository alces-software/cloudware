# frozen_string_literal: true

require 'parse_param'

RSpec.describe Cloudware::ParseParam do
  subject { described_class.new(context) }
  let(:context) { build(:context) }

  describe '#pair' do
    let(:key) { :my_key }

    it 'replaces nil values with empty string' do
      expect(subject.pair(key, nil)).to eq('')
    end

    it 'returns empty strings' do
      expect(subject.pair(key, '')).to eq('')
    end

    it 'returns the value for a regular string' do
      regular = 'I-start-with-a-regular-character'
      expect(subject.pair(key, regular)).to eq(regular)
    end

    context 'when referencing a missing deployment' do
      it 'returns an empty string' do
        input = '*missing-deployment'
        expect(subject.pair(key, input)).to eq('')
      end
    end

    context 'with a deployment' do
      let(:result_string) { 'value from deployment' }
      let(:other_key) { :my_super_other_key }
      let(:other_result) { 'I am the other keys result' }
      let(:deployment_results) do
        { key => result_string, other_key => other_result }
      end
      let(:deployment_name) { 'my-deployment' }
      let(:deployment) do
        build(:deployment, name: deployment_name, results: deployment_results)
      end

      before { context.with_deployment(deployment) }

      context 'with *<deployment-name> inputs' do
        it 'returns the deployment results matching the key' do
          input_value = "*#{deployment_name}"
          expect(subject.pair(key, input_value)).to eq(result_string)
        end
      end

      context 'with *<deployment-name>.<other-key>' do
        it 'ignores the input key an uses the other-key instead' do
          input_value = "*#{deployment_name}.#{other_key}"
          expect(subject.pair(key, input_value)).to eq(other_result)
        end
      end
    end
  end
end