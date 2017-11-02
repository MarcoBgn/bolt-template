# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Utility::Kpis::Watchable, type: :model do
  let(:targets) { nil }
  let(:attrs) { { title: 'my_watchy', targets: targets } }
  let(:watchable) { described_class.new(attrs) }

  describe 'Creation' do
    subject { watchable }
    it 'sets the attributes' do
      expect(subject.title).to eq('my_watchy')
      expect(subject.targets).to eq([])
    end

    describe '#targets' do
      subject { watchable.targets }

      it { is_expected.to eq([]) }

      context 'with targets defined' do
        let(:targets) { [Utility::Kpis::Target.new] }
        it { is_expected.to eq(targets) }
      end
    end
  end

  describe '#triggered?' do
    let(:targets) { [Utility::Kpis::Target.new, Utility::Kpis::Target.new] }
    subject { watchable.triggered? }
    it { is_expected.to eq(false) }

    context 'when some targets of the watchable are triggered' do
      before { allow(watchable.targets.last).to receive(:triggered?).and_return(true) }
      it { is_expected.to eq(true) }
    end
  end
end
