# frozen_string_literal: true

require 'bucky/test_equipment/pageobject/base_pageobject'
module Services
  module BuckyHandsOn
    module Pc
      module PageObject
        class GithubSearchList < Bucky::TestEquipment::PageObject::BasePageObject
          protected

          # add some user operations for this page
          # sample ====================
          # @param [Hash] args
          # def search_freeword(**args)
          #  freeword_form.send_keys(args[:word])
          #  freeword_form.submit
          # end
        end
      end
    end
  end
end
