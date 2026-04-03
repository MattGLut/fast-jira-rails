require 'rails_helper'

RSpec.describe NavigationHelper, type: :helper do
  describe '#nav_link' do
    it 'renders an active nav link when current_page? matches' do
      allow(helper).to receive(:current_page?).with('/projects').and_return(true)
      allow(helper).to receive(:request).and_return(instance_double(ActionDispatch::Request, path: '/projects'))

      html = helper.nav_link('Projects', '/projects', icon: '📁')

      expect(html).to include('href="/projects"')
      expect(html).to include('bg-gray-800 text-white shadow-lg shadow-black/20')
      expect(html).to include('📁')
      expect(html).to include('Projects')
    end

    it 'renders an active nav link when request path matches active_paths' do
      allow(helper).to receive(:current_page?).with('/projects').and_return(false)
      allow(helper).to receive(:request).and_return(instance_double(ActionDispatch::Request, path: '/projects/123/tickets'))

      html = helper.nav_link('Projects', '/projects', active_paths: ['/projects'])

      expect(html).to include('bg-gray-800 text-white shadow-lg shadow-black/20')
    end

    it 'renders an inactive nav link when no path matches' do
      allow(helper).to receive(:current_page?).with('/projects').and_return(false)
      allow(helper).to receive(:request).and_return(instance_double(ActionDispatch::Request, path: '/dashboard'))

      html = helper.nav_link('Projects', '/projects')

      expect(html).to include('text-gray-300 hover:bg-gray-800/70 hover:text-white')
    end
  end
end
