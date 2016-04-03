module Paperclip
  module Validators
    class AttachmentAtLeastDimensionsValidator < ActiveModel::EachValidator
      def initialize(options)
        super
      end

      def self.helper_method_name
        :validates_attachment_at_least_dimensions
      end

      def validate_each(record, attribute, value)
        return unless value.queued_for_write[:original]

        begin
          dimensions = Paperclip::Geometry.from_file(value.queued_for_write[:original].path)
          record.errors.add(attribute.to_sym, :height_at_least, actual_dimension: dimensions.height.to_i, dimension: options[:dimensions][:height]) unless dimensions.height >= options[:dimensions][:height].to_f
          record.errors.add(attribute.to_sym, :width_at_least, actual_dimension: dimensions.width.to_i, dimension: options[:dimensions][:width]) unless dimensions.width >= options[:dimensions][:width].to_f
        rescue Paperclip::Errors::NotIdentifiedByImageMagickError
          Paperclip.log("cannot validate dimensions on #{attribute}")
        end
      end
    end

  end
end
