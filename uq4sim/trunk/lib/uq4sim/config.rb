module Uq4sim

  def load_configuration config_file='config.yml'
    YAML.load_file(config_file).each do |key,value|
      instance_variable_set( "@#{key}", value )
    end
  end

end
