# -*- coding: utf-8 -*-

require 'RMagick'

class Nude
  class NudeError < StandardError
  end

  Skin = Struct.new(:id, :skin, :region, :x, :y, :checked)

  class << self
    def nude?(path_or_io)
      parse(path_or_io).nude?
    end

    def parse(path_or_io)
      new(path_or_io).parse
    end

    private :new
  end

  attr_reader :image

  attr_reader :result
  alias_method :nude?, :result

  attr_reader :message

  def initialize(path_or_io)
    # get the image data
    @image = (
      case path_or_io
      when Magick::Image
        path_or_io
      when IO
        Magick::Image.from_blob(path_or_io.read).first
      else
        Magick::Image.read(path_or_io).first
      end
    )
    unless @image
      raise NudeError, 'Could not read image data'
    end
    @skin_map = []
    @skin_regions = []
    @detected_regions = []
    @merge_regions = []
    @width = @image.columns
    @height = @image.rows
    @total_pixels = @width * @height
    @last_from = -1
    @last_to = -1
    @result = nil
    @message = nil
  end

  def parse
    return self unless @result.nil?

    # iterate the image from the top left to the bottom right
    @image.each_pixel do |pixel, x, y|
      r  = pixel.red   / 256
      g  = pixel.green / 256
      b  = pixel.blue  / 256
      id = x + y * @width + 1

      if not classify_skin(r, g, b)
        @skin_map << Skin.new(id, false, 0, x, y, false)
      else
        @skin_map << Skin.new(id, true, 0, x, y, false)

        region = -1
        check_indexes = [
          id - 2,
          id - @width - 2,
          id - @width - 1,
          id - @width
        ]
        checker = false

        check_indexes.each do |index|
          if @skin_map[index] && @skin_map[index].skin
            if @skin_map[index].region != region &&
                region != -1 &&
                @last_from != region &&
                @last_to != @skin_map[index].region
              add_merge(region, @skin_map[index].region)
            end
            region = @skin_map[index].region
            checker = true
          end
        end

        if not checker
          @skin_map[id - 1].region = @detected_regions.size
          @detected_regions << [@skin_map[id - 1]]
          next
        else
          if region > -1
            @detected_regions[region] ||= []
            @skin_map[id - 1].region = region
            @detected_regions[region] << @skin_map[id - 1]
          end
        end
      end
    end

    merge(@detected_regions, @merge_regions)
    analyse_regions

    self
  end

  def inspect
    variables = [:@result, :@message, :@image].map { |key|
      key.to_s + "=" + instance_variable_get(key).inspect
    }.join(", ")
    "#<#{self.class}:0x#{object_id} #{variables}>"
  end

  private

  def add_merge(from, to)
    @last_from = from
    @last_to = to

    from_index = -1
    to_index = -1

    @merge_regions.each.with_index do |region, index|
      region.each do |r_index|
        from_index = index if r_index == from
        to_index   = index if r_index == to
      end
    end

    if from_index != -1 && to_index != -1
      if from_index != to_index
        region = @merge_regions[from_index].concat(@merge_regions.delete_at(to_index))
        @merge_regions[from_index] = region
      end
      return
    end

    if from_index == -1 && to_index == -1
      @merge_regions << [from, to]
      return
    end

    if from_index != -1 && to_index == -1
      @merge_regions[from_index] << to
      return
    end

    if from_index == -1 && to_index != -1
      @merge_regions[to_index] << from
      return
    end
  end

  # function for merging detected regions
  def merge(detected_regions, merge_regions)
    new_detected_regions = []

    # merging detected regions
    merge_regions.each.with_index do |region, index|
      new_detected_regions[index] ||= []
      region.each do |r_index|
        region = new_detected_regions[index].concat(detected_regions[r_index])
        new_detected_regions[index] = region
        detected_regions[r_index] = []
      end
    end

    # push the rest of the regions to the detRegions array
    # (regions without merging)
    detected_regions.each do |region|
      new_detected_regions << region if region.size > 0
    end

    # clean up
    clear_regions(new_detected_regions)
  end

  # clean up function
  # only pushes regions which are bigger than a specific amount to the final result
  def clear_regions(detected_regions)
    detected_regions.each do |region|
      @skin_regions << region if region.size > 30
    end
  end

  def analyse_regions
    # if there are less than 3 regions
    if @skin_regions.size < 3
      @message = "Less than 3 skin regions (#{@skin_regions.size})"
      return @result = false
    end

    # sort the skin regions
    @skin_regions = @skin_regions.sort_by { |region| - region.size }

    # count total skin pixels
    total_skin = @skin_regions.map(&:size).reduce(:+).to_f

    # check if there are more than 15% skin pixel in the image
    if total_skin / @total_pixels * 100 < 15
      # if the percentage lower than 15, it's not nude!
      @message = "Total skin parcentage lower than 15 (#{total_skin / @total_pixels * 100}%)"
      return @result = false
    end

    # check if the largest skin region is less than 35% of the total skin count
    # AND if the second largest region is less than 30% of the total skin count
    # AND if the third largest region is less than 30% of the total skin count
    if @skin_regions[0].size / total_skin * 100 < 35 &&
        @skin_regions[1].size / total_skin * 100 < 30 &&
        @skin_regions[2].size / total_skin * 100 < 30
      @message = 'Less than 35%, 30%, 30% skin in the biggest regions'
      return @result = false
    end

    # check if the number of skin pixels in the largest region is less than 45% of the total skin count
    if @skin_regions.first.size / total_skin * 100 < 45
      @message = "The biggest region contains less than 45% (#{@skin_regions.first.size / total_skin * 100}%)"
      return @result = false
    end

    # TODO:
    # build the bounding polygon by the regions edge values:
    # Identify the leftmost, the uppermost, the rightmost, and the lowermost skin pixels of the three largest skin regions.
    # Use these points as the corner points of a bounding polygon.

    # TODO:
    # check if the total skin count is less than 30% of the total number of pixels
    # AND the number of skin pixels within the bounding polygon is less than 55% of the size of the polygon
    # if this condition is true, it's not nude.

    # TODO: include bounding polygon functionality
    # if there are more than 60 skin regions and the average intensity within the polygon is less than 0.25
    # the image is not nude
    if @skin_regions.size > 60
      @message = "More than 60 skin regions (#{@skin_regions.size})"
      return @result = false
    end

    # otherwise it is nude
    @result = true
  end

  # A Survey on Pixel-Based Skin Color Detection Techniques
  def classify_skin(r, g, b)
    rgb_classifier =
      r > 95 &&
      g > 40 && g < 100 &&
      b > 20 &&
      [r, g, b].max - [r, g, b].min > 15 &&
      (r - g).abs > 15 &&
      r > g &&
      r > b

    nr, ng, nb = *to_normalized_rgb(r, g, b)
    norm_rgb_classifier =
      nr / ng > 1.185 &&
      (r * b).to_f / ((r + g + b) ** 2) > 0.107 &&
      (r * g).to_f / ((r + g + b) ** 2) > 0.112

    h, s, v = *to_hsv(r, g, b)
    hsv_classifier =
      h > 0 &&
      h < 35 &&
      s > 0.23 &&
      s < 0.68

    # ycc doesnt work

    rgb_classifier || norm_rgb_classifier || hsv_classifier
  end

  def to_normalized_rgb(r, g, b)
    sum = (r + g + b).to_f

    [
      r / sum,
      g / sum,
      b / sum
    ]
  end

  def to_hsv(r, g, b)
    h = 0
    sum = (r + g + b).to_f
    max = [r, g, b].max.to_f
    min = [r, g, b].min.to_f
    diff = (max - min).to_f

    if max == r
      h = (g - b) / diff
    elsif max == g
      h = 2 + ((g - r) / diff)
    else
      h = 4 + ((r - g) / diff)
    end

    h *= 60
    h += 360 if h < 0

    [
      h,
      1.0 - (3.0 * (min / sum)),
      (1.0 / 3.0) * max
    ]
  end
end
