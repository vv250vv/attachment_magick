require "attachment_magick/dragonfly/dragonfly_mongo"
require "attachment_magick/dsl"
require "attachment_magick/image"

module AttachmentMagick
  attr_accessor :attachment_magick_default_options

  def attachment_magick(&block)
    embeds_many :images, :class_name => "AttachmentMagick::Image"
    
    default_grids = generate_grids
    map           = DSL.new(self, default_grids)
    map.instance_eval(&block)
    
    @attachment_magick_default_options = {:styles => map.styles || default_grids}
    grid_methods  
  end

  def generate_grids(column_amount=19, column_width=54, gutter=0, only=[])
    hash = {}
    grids_to_create = only.empty? ? 1.upto(column_amount) : only
    
    grids_to_create.each do |key|
      grid  = ("grid_#{key}").to_sym
      value = (key * column_width) + (gutter * (key - 1))
      hash.merge!({grid => {:width => value}})
    end

    return hash
  end
  
  def grid_methods
    @attachment_magick_default_options[:styles].each do |key, value|
      define_method "#{key.to_s}" do
        return "#{value[:width]}x#{value[:height]}"
      end
    end
  end
  
  private :generate_grids
  private :grid_methods
end