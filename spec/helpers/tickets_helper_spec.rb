require 'rails_helper'

RSpec.describe TicketsHelper, type: :helper do
  describe '#priority_badge_class' do
    it 'returns expected class for each known priority' do
      expect(helper.priority_badge_class(:critical)).to eq('bg-red-500/20 text-red-300 border border-red-400/40')
      expect(helper.priority_badge_class(:high)).to eq('bg-orange-500/20 text-orange-300 border border-orange-400/40')
      expect(helper.priority_badge_class(:medium)).to eq('bg-yellow-500/20 text-yellow-300 border border-yellow-400/40')
      expect(helper.priority_badge_class(:low)).to eq('bg-emerald-500/20 text-emerald-300 border border-emerald-400/40')
    end

    it 'returns fallback class for unknown priority' do
      expect(helper.priority_badge_class(:unknown)).to eq('bg-gray-700 text-gray-200 border border-gray-600')
    end
  end

  describe '#type_icon' do
    it 'returns expected icon for each known ticket type' do
      expect(helper.type_icon(:story)).to eq('📖')
      expect(helper.type_icon(:task)).to eq('✅')
      expect(helper.type_icon(:bug)).to eq('🐛')
    end

    it 'returns fallback icon for unknown type' do
      expect(helper.type_icon(:chore)).to eq('🎫')
    end
  end

  describe '#status_badge_class' do
    it 'returns expected class for each known status' do
      expect(helper.status_badge_class(:todo)).to eq('bg-slate-500/20 text-slate-200 border border-slate-400/40')
      expect(helper.status_badge_class(:in_progress)).to eq('bg-sky-500/20 text-sky-200 border border-sky-400/40')
      expect(helper.status_badge_class(:code_review)).to eq('bg-violet-500/20 text-violet-200 border border-violet-400/40')
      expect(helper.status_badge_class(:qa)).to eq('bg-amber-500/20 text-amber-200 border border-amber-400/40')
      expect(helper.status_badge_class(:done)).to eq('bg-emerald-500/20 text-emerald-200 border border-emerald-400/40')
    end

    it 'returns fallback class for unknown status' do
      expect(helper.status_badge_class(:blocked)).to eq('bg-gray-700 text-gray-100 border border-gray-600')
    end
  end
end
