require 'test_helper'

module Unbounded
  class LobjectShowTestCase < IntegrationTestCase
    def test_related_resource_type_video
      lobject = lobjects(:unbounded)
      visit "/resources/#{lobject.id}"
      assert find('.lobject-related-resource').has_content?('Video')
    end

    def test_related_resource_type_resource
      lobject = lobjects(:easol)
      visit "/resources/#{lobject.id}"
      assert find('.lobject-related-resource').has_content?('Resource')
    end
  end
end
