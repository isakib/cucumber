$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'yaml'
require 'cucumber/platform'
require 'rubygems'
require 'cucumber/parser'
require 'cucumber/version'
require 'cucumber/step_mother'
require 'cucumber/cli'
require 'cucumber/broadcaster'
require 'cucumber/core_ext/exception'

module Cucumber
  class << self
    attr_reader :lang
    
    def load_language(lang) #:nodoc:
      return if @lang
      @lang = lang
      alias_step_definitions(lang)
      Parser.load_parser(keyword_hash)
    end

    # Returns a Hash of the currently active
    # language, or for a specific language if +lang+ is
    # specified.
    def keyword_hash(lang=@lang)
      LANGUAGES[lang]
    end
    
    def alias_step_definitions(lang) #:nodoc:
      keywords = %w{given when then and but}.map{|keyword| keyword_hash(lang)[keyword]}
      alias_steps(keywords)
    end
    
    # Sets up additional aliases for Given, When and Then.
    # Try adding the following to your <tt>support/env.rb</tt>:
    #
    #   # Given When Then in Norwegian
    #   Cucumber.alias_steps %w{Gitt Naar Saa}
    #
    # You cannot use special characters here, because methods
    # with special characters is not valid Ruby code
    #
    def alias_steps(keywords)
      keywords.each do |adverb|
        StepMother.class_eval do
          alias_method adverb, :register_step_definition
        end

        StepMother::WorldMethods.class_eval do
          alias_method adverb, :__cucumber_invoke
        end
      end
    end
  end  

  # Make sure we always have English aliases
  alias_step_definitions('en')
end