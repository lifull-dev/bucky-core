# frozen_string_literal: true

require '/bucky-core/lib/bucky/test_equipment/pageobject/base_pageobject'
module Services
  module ServiceA
    module Pc
      module PageObject
        class Index < Bucky::TestEquipment::PageObject::BasePageObject
          def click_single_element(_)
            links.click
          end

          def click_multiple_element(_)
            links[1].click
          end
        end
      end
    end
  end
end
