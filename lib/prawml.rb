require "prawml/version"
require "prawn"
require "barby/outputter/prawn_outputter"
require "active_support/inflector"
require "active_support/core_ext"
require "yaml"

module Prawml

  class PDF
	
    attr_reader :pdf    

    SYMBOLOGIES = {
      "bookland" => "Bookland",
      "code_128" => "Code128",
      "code_25" => "Code25",
      "code_25_iata" => "Code25IATA",
      "code_25_interleaved" => "Code25Interleaved",
      "code_39" => "Code39",
      "code_93" => "Code93",
      "data_matrix" => "DataMatrix",
      "ean_13" => "EAN13",
      "ean_8" => "EAN8",
      "gs1_128" => "GS1128",
      "pdf_417" => "Pdf417",
      "qr_code" => "QrCode",
      "upc_supplemental" => "UPCSupplemental"
    }

    def initialize(yaml, options = {})
        raise "You must pass a valid YAML file or a string with YAML to generate PDF." if yaml.empty?

        begin
          rules = File.open(yaml)
        rescue
          rules = yaml
        end
        @rules = YAML::load(rules)

        @options = {
          :page_size => "A4",
          :page_layout => :portrait
        }.merge options

        template_img = @options.delete(:template_img)
        
	
        @pdf = Prawn::Document.new @options

        unless template_img.nil?
          draw_image template_img[:path], [template_img[:x], template_img[:y], {:width => template_img[:width], :height => template_img[:height]}]
        end
    end

    def generate(collection)
        defaults = {
            :style => :normal,
            :size => 12,
            :align => :left,
            :format => false,
            :font => 'Times-Roman',
            :type => :text,
            :color => '000000',
            :fixed => false
        }

        @rules.each do |field, draws|
            unless draws[0].is_a? Array
              draws = [draws]
            end

            draws.each do |params|
              params[2] = defaults.merge(params[2] || {})
              params[2].symbolize_keys!
              params[2][:style] = params[2][:style].to_sym

              set_options params[2]

	            value = collection.respond_to?(field.to_sym) ? collection.send(field.to_sym) : collection[field.to_sym]

              send :"draw_#{params[2][:type]}", value, params unless value.nil?
            end
        end

        @pdf
    end

    protected

    def draw_text(text, params)
        xpos, ypos, options = params

        @pdf.draw_text text, :at => [align(text, xpos, options[:align]), ypos]
    end

    def draw_barcode(text, params)
        xpos, ypos, options = params

        begin
          symbology = options[:symbology].to_s

          require "barby/barcode/#{symbology}"

          barby_module = "Barby::#{SYMBOLOGIES[symbology]}"

          barcode = ActiveSupport::Inflector.constantize(barby_module).new(text)

          outputter = Barby::PrawnOutputter.new(barcode)
          outputter.annotate_pdf(@pdf, options.merge({:x => xpos, :y => ypos}))
        rescue LoadError
          raise "Symbology '#{symbology}' is not defined. Please see https://github.com/toretore/barby/wiki/Symbologies for more information on available symbologies."
        end
    end

    def draw_image(image, params)
      xpos, ypos, options = params

      @pdf.image image, :at => [xpos, ypos], :width => options[:width], :height => options[:height]
    end

    private

    def set_options(options)
      @pdf.fill_color options[:color]
      @pdf.font options[:font], options
    end

    def align(text, position, alignment)
        font = @pdf.font
        width = font.compute_width_of(text.to_s.parameterize)

        case alignment.to_sym
        when :center then
            position - width/2
        when :right then
            position - width
        else
            position
        end
    end
  end

end
