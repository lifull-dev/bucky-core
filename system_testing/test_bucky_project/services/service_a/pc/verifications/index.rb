# frozen_string_literal: true

require '/bucky-core/lib/bucky/test_equipment/verifications/e2e_verification'
module Services
  module ServiceA
    module Pc
      module Verifications
        class Index < Bucky::TestEquipment::Verifications::E2eVerification
          def click_single_element(_)
            @pages.index.links.click
          end

          def click_multiple_element(_)
            @pages.index.links[1].click
          end
        end
      end
    end
  end
end
