module Dg
  class RailsUpgrader
    def initialize(text)
      @text = text
    end

    def convert_validators
      output = []

      @text.each do |line|
        if method = match(line)
          output << eval("#{method}(line)")
        else
          output << line
        end
      end
      output.to_s
    end

    ##########
    ##########
    private
    ##########
    ##########

    def match(line)
      validation_on_regex = /before_validation_on_create|before_validation_on_update|after_validation_on_create|after_validation_on_update/
      validate_on_regex = /validate_on_create|validate_on_update/

      if validation_on_regex.match(line)
        method = 'convert_validation_on'
        not_found = false
      elsif validate_on_regex.match(line)
        method = 'convert_validate_on'
        not_found = false
      end

      method
    end
    
    def convert_validation_on(line)
      matches = line[/([ \t]*)(\w+)_validation_on_(\w+)[ \t]+:(.*)/, 1]
      spaces = $1
      b_or_a = $2
      method = $3
      block = $4
      "#{spaces}#{b_or_a}_validation(:on => :#{method}) {:#{block}}\n"
    end

    def convert_validate_on(line)
      matches = line[/([ \t]*)validate_on_(\w+)[ \t]+:(.*)/, 1]
      spaces = $1
      method = $2
      block = $3
      "#{spaces}validate :#{block}, :on => :#{method}\n"
    end
    
  end
end

# before_validation_on_create    :before_validation_on_create
# before_validation(:on => :create) {:before_validation_on_create}

# before_validation_on_update :before_validation_on_update
# before_validation(:on => :update) {:before_validation_on_update}

# after_validation_on_create :after_validation_on_create
# after_validation(:on => :create) {:after_validation_on_create}

# after_validation_on_update :after_validation_on_update
# after_validation(:on => :update) {:after_validation_on_update}

# validate_on_create :check_tos, :validate_promotion_code
# validate :check_tos, :validate_promotion_code, :on => :create

# before_validation_on_create :geocode_address, :set_default_wine_preferences
# before_validation(:on => :create) {:geocode_address, :set_default_wine_preferences}
