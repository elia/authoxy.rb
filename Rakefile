task :gem do
  puts "Packaging..."
  gemspec = File.join('ruby-authoxy.gemspec')
  sh('gem', 'build', gemspec)
end


namespace :gem do
  desc 'Generates/refreshes manifest (i.e. the list of files in order to create the gem).'
  task :manifest do
    puts 'Generating Manifest...'
    sh %q{find . -type f | egrep -v "(.git\/|CVS\/|nbproject\/|pkg\/|\.gitignore$|\.gem$|.tmproj$|\.DS_Store$|\.log$)" | sed 's/\.\///g' > Manifest.txt}
  end
  
  file 'Manifest.txt' do
    Rake::Task.invoke :manifest
  end
  
  desc 'Packages the application into a gem.'
  task :package => ['Manifest.txt'] do
    puts "Packaging..."
    gemspec = File.join('ruby-authoxy.gemspec')
    sh('gem', 'build', gemspec)
  end
  
  desc 'Installs the gem'
  task :install do
    sh('gem install *.gem')
  end
  
  desc 'Rebuilds and reinstalls the gem...'
  task :reinstall => [:manifest, :package, :install]
end