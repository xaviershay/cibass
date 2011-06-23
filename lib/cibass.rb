class Cibass
  def self.configure(&block)
    @config = Config.new
    block.call(@config)
  end

  def self.instance=(value)
    @instance = value
  end

  def self.config
    @config
  end
end
