# frozen_string_literal: true

#==============================================================================
# Copyright (C) 2019-present Alces Flight Ltd.
#
# This file is part of Flight Cloud.
#
# This program and the accompanying materials are made available under
# the terms of the Eclipse Public License 2.0 which is available at
# <https://www.eclipse.org/legal/epl-2.0>, or alternative license
# terms made available by Alces Flight Ltd - please direct inquiries
# about licensing to licensing@alces-flight.com.
#
# Flight Cloud is distributed in the hope that it will be useful, but
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, EITHER EXPRESS OR
# IMPLIED INCLUDING, WITHOUT LIMITATION, ANY WARRANTIES OR CONDITIONS
# OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR A
# PARTICULAR PURPOSE. See the Eclipse Public License 2.0 for more
# details.
#
# You should have received a copy of the Eclipse Public License 2.0
# along with Flight Cloud. If not, see:
#
#  https://opensource.org/licenses/EPL-2.0
#
# For more information on Flight Cloud, please visit:
# https://github.com/openflighthpc/flight-cloud
#===============================================================================

require 'cloudware/replacement_factory'

RSpec.describe Cloudware::ReplacementFactory do
  shared_context 'parse-param-deployment' do
    let(:result_string) { 'value from deployment' }
    let(:other_key) { :my_super_other_key }
    let(:other_result) { 'I am the other keys result' }
    let(:deployment_results) do
      { key => result_string, other_key => other_result }
    end
    let(:deployment_name) { 'my-deployment' }
    let(:deployment) do
      build(:deployment, cluster: cluster, name: deployment_name, results: deployment_results)
    end

    before { FlightConfig::Core.write(deployment) }
  end

  subject { described_class.new(cluster, deployment_name) }

  let(:cluster) { 'test-cluster' }
  let(:deployment_name) { 'my-deployment-name' }
  let(:key) { :my_key }

  describe '#parse_key_pair' do
    it 'replaces nil values with empty string' do
      expect(subject.parse_key_pair(key, nil)).to eq('')
    end

    it 'returns empty strings' do
      expect(subject.parse_key_pair(key, '')).to eq('')
    end

    it 'returns the value for a regular string' do
      regular = 'I-start-with-a-regular-character'
      expect(subject.parse_key_pair(key, regular)).to eq(regular)
    end

    context 'when referencing a missing deployment' do
      it 'returns an empty string' do
        input = '*missing-deployment'
        expect(subject.parse_key_pair(key, input)).to eq('')
      end
    end

    context 'with a deployment' do
      include_context 'parse-param-deployment'

      context 'with *<deployment-name> inputs' do
        it 'returns the deployment results matching the key' do
          input_value = "*#{deployment_name}"
          expect(subject.parse_key_pair(key, input_value)).to eq(result_string)
        end
      end

      context 'with *<deployment-name>.<other-key>' do
        it 'ignores the input key an uses the other-key instead' do
          input_value = "*#{deployment_name}.#{other_key}"
          expect(subject.parse_key_pair(key, input_value)).to eq(other_result)
        end
      end
    end
  end

  describe '#build' do
    shared_examples 'a default replacement' do
      it 'includes the deployment name' do
        replacements = subject.build(input_string)
        expect(replacements).to include(deployment_name: deployment_name)
      end
    end

    shared_examples 'a literal key value replacement' do
      it 'returns the key value pairing' do
        expect(subject.build(input_string)).to include(key => value)
      end
    end

    shared_examples 'an invalid input' do
      it 'issues an user error' do
        expect { subject.build(value) }.to raise_error(Cloudware::InvalidInput)
      end
    end

    context 'when the string is missing an =' do
      let(:value) { 'i-am-not-a-key-value-pair' }

      it_behaves_like 'an invalid input'
    end

    context 'with a regular key=value string' do
      let(:value) { 'my-value' }
      let(:input_string) { "#{key}=#{value}" }

      it_behaves_like 'a default replacement'
      it_behaves_like 'a literal key value replacement'
    end

    context 'with a multi {key1,key2}=value string' do
      let(:value) { 'my-value' }
      let(:input_string) { "other_key,#{key}=#{value}" }

      it_behaves_like 'a default replacement'
      it_behaves_like 'a literal key value replacement'
    end

    context 'when the value contains a correctly quoted space' do
      let(:value) { 'some string with spaces' }
      let(:input_string) { "#{key}='#{value}'" }

      it_behaves_like 'a default replacement'
      it_behaves_like 'a literal key value replacement'
    end

    context 'with an incorrectly quoted string' do
      let(:value) { '"missing-closing-quote' }

      it_behaves_like 'an invalid input'
    end

    context 'with a deployment' do
      let(:input_string) { "#{key}=*#{deployment_name}" }

      include_context 'parse-param-deployment'

      it_behaves_like 'a default replacement'
    end

    context 'with multi key-pair input string' do
      let(:test_hash) { { key1: 'string1', key2: 'string2' } }
      let(:input_string) do
        test_hash.reduce('') do |memo, (key, value)|
          memo += " #{key}=#{value}"
        end
      end

      it_behaves_like 'a default replacement'

      it 'returns all the key pairs' do
        expect(subject.build(input_string)).to include(**test_hash)
      end
    end

    context 'with an empty string input' do
      let(:input_string) { '' }

      it_behaves_like 'a default replacement'
    end

    context 'wit a nil input' do
      let(:input_string) { nil }

      it_behaves_like 'a default replacement'
    end
  end
end
