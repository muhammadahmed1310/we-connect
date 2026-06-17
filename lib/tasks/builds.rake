namespace :builds do

  desc 'Update the build number and tag the build'
  task tag_build: :environment do
    build_number = File.readlines('BUILD_NUMBER').first.to_i
    version = File.readlines('VERSION').first.strip
    build_number += 1
    File.open('BUILD_NUMBER', 'w') { |file| file.write(build_number) }
    puts "Build number updated to #{build_number}"

    tag = "build-#{version}-#{build_number}"
    puts "Tagging build with #{tag}"

    # Tag the build
    `git commit -am "Build #{tag}"`
    `git tag -a -f -m "Tagging build #{tag}" "#{tag}"`
    `git push --follow-tags`
  end


end
