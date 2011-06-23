namespace :test do
  [:acceptance].each do |type|
    desc "Run all #{type} tests"
    task type do
      Dir["test/#{type}/**/*_test.rb"].each do |x|
        require_relative x
      end
    end
  end
end

task default: :'test:acceptance'
