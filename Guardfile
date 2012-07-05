guard "bundler" do
  watch("Gemfile")
  watch(/^.+\.gemspec/)
end

guard "spork", rspec_port: 2730 do
  watch("Gemfile")
  watch("Gemfile.lock")
  watch(".rspec")              { :rspec }
  watch("spec/spec_helper.rb") { :rspec }
end

guard "rspec", cli: '--drb --drb-port 2727' do
  watch(%r{^spec/.+_spec\.rb$})

  watch("lib/profiler.rb") { "spec" }

  watch(%r{^lib/profiler/(.+)\.rb$})          { |m| "spec/#{m[1]}_spec.rb" }
end
