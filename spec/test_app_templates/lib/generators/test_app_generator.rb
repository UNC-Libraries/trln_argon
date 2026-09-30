require 'rails/generators'

class TestAppGenerator < Rails::Generators::Base
  source_root './spec/test_app_templates'

  # if you need to generate any additional configuration
  # into the test app, this generator will be run immediately
  # after setting up the application

  # BL8's Sprockets asset generator skips creating app/assets/config/manifest.js
  # on Rails > 7 (it assumes you're using Propshaft/Importmap by default), so we
  # have to create it ourselves here, mirroring what BL7 used to do. Without this
  # file, Sprockets::Railtie raises Sprockets::Railtie::ManifestNeededError as soon
  # as any `bin/rails` command boots the app. Since trln_argon.gemspec already
  # depends on dartsass-sprockets (which pulls in sprockets-rails), this can
  # happen starting with the very first `generate` call below, so this must run
  # before any of them.
  # https://github.com/projectblacklight/blacklight/blob/release-8.x/lib/generators/blacklight/assets/sprockets_generator.rb
  def ensure_sprockets_manifest
    say_status('info', '===============================', :magenta)
    say_status('info', 'Ensuring Sprockets manifest.js', :magenta)
    say_status('info', '===============================', :magenta)

    manifest = 'app/assets/config/trln_argon_manifest.js'
    create_file manifest, "//= link_tree ../images\n" unless File.exist?(manifest)
    append_to_file manifest, "//= link application.js\n" unless IO.read(manifest)
                                                                  .include?('link application.js')
    append_to_file manifest, "//= link blacklight/manifest.js\n" unless IO.read(manifest)
                                                                          .include?('link blacklight/manifest.js')

    # Without this, the default Sprockets 4 manifest will raise an exception
    # if app/assets/images is empty.
    empty_directory 'app/assets/images'
  end

  def add_gems
    gem 'blacklight', '~> 8.0'

    Bundler.with_unbundled_env do
      run 'bundle install'
    end
  end

  def run_blacklight_generator
    say_status('info', '================================', :magenta)
    say_status('info', 'Generating Blacklight w/o assets', :magenta)
    say_status('info', '================================', :magenta)

    # Skip the default BL assets generator via --skip-assets:
    generate 'blacklight:install', '--devise', '--skip-solr', '--skip-assets'

    # We need to explicitly specify BL8's Sprockets assets generator, else
    # BL will assume we want to use Propshaft and/or Importmap. See:
    # https://github.com/projectblacklight/blacklight/blob/release-8.x/lib/generators/blacklight/assets_generator.rb
    # https://github.com/projectblacklight/blacklight/blob/release-8.x/lib/generators/blacklight/assets/sprockets_generator.rb
    say_status('info', '========================================', :magenta)
    say_status('info', 'Generating Blacklight assets w/Sprockets', :magenta)
    say_status('info', '========================================', :magenta)
    generate 'blacklight:assets:sprockets'
  end

  def remove_blacklight_scss
    # We don't want the BL-generated blacklight.scss file since we are already using
    # trln_argon_dependencies.scss to @import bootstrap & blacklight styles.
    say_status('info', '=============================', :magenta)
    say_status('info', 'Removing Blacklight SCSS file', :magenta)
    say_status('info', '=============================', :magenta)
    remove_file 'app/assets/stylesheets/blacklight.scss'
  end

  # The sassc-rails gem is added by the BL assets generator but we don't want it.
  # We'll use dartsass-sprockets instead.
  # https://github.com/projectblacklight/blacklight/blob/release-8.x/lib/generators/blacklight/assets/sprockets_generator.rb#L33
  def remove_sassc_rails
    say_status('info', '====================', :magenta)
    say_status('info', 'Removing SassC-Rails', :magenta)
    say_status('info', '====================', :magenta)
    gsub_file('Gemfile', /^.*gem\s+["']sassc-rails["'].*$/, '')
  end

  def install_dartsass
    say_status('info', '===================', :magenta)
    say_status('info', 'Installing DartSass', :magenta)
    say_status('info', '===================', :magenta)
    gem 'dartsass-sprockets' unless IO.read('Gemfile').include?('dartsass-sprockets')
    Bundler.with_unbundled_env do
      run 'bundle install'
    end

    # Remove the default Rails-generated application.css in favor of application.scss
    # (needed because we're using DartSass with Sprockets)
    remove_file 'app/assets/stylesheets/application.css'
    create_file 'app/assets/stylesheets/application.scss'
  end

  def install_engine
    say_status('info', '============================', :magenta)
    say_status('info', 'Generating TRLN Argon engine', :magenta)
    say_status('info', '============================', :magenta)
    generate 'trln_argon:install'

    Bundler.with_unbundled_env do
      run 'bundle install'
    end
  end
end
