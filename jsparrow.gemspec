Gem::Specification.new do |s|
  s.name = %q{jsparrow}
  s.version = "1.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Leandro Silva (CodeZone)"]
  s.date = %q{2009-03-08}
  s.email = %q{leandrodoze@gmail.com}
  s.extra_rdoc_files = ["README.rdoc", "LICENSE"]
  s.files = ["LICENSE", "VERSION.yml", "README.rdoc", "Rakefile", "lib/jee.rb", "lib/error.rb", "lib/jsparrow.rb", "lib/messaging.rb", "lib/connection.rb", "lib/jee", "lib/jee/jsparrow-essential.jar", "lib/jee/jms.jar", "lib/jee/javaee-1.5.jar", "spec/spec_helper.rb", "spec/messaging_spec.rb", "spec/connection_spec.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/leandrosilva/jsparrow}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{JSparrow is a JMS client based on JRuby based}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
    else
    end
  else
  end
end
